//
//  ChatFirestore.swift
//  ChatFirestore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage

let logger = ChatLogger()

/// Implementation of `ChatNetworkServicing` for Firestore backends
open class ChatFirestore<Models: ChatFirestoreModeling>: ChatNetworkServicing {
    public typealias NetworkModels = Models
    public typealias UserManager = ChatFirestoreUserManager<UserFirestore>
    
    public typealias ConversationFirestore = Models.NetworkConversation
    public typealias MessageFirestore = Models.NetworkMessage
    public typealias UserFirestore = Models.NetworkUser
    public typealias MessageSpecificationFirestore = Models.NetworkMessageSpecification
    
    let config: ChatFirestoreConfig
    var constants: ChatFirestoreConstants {
        config.constants
    }
    let decoder: JSONDecoder
    
    // Logger
    public var logLevel: ChatLogLevel {
        get { logger.level }
        set { logger.level = newValue }
    }

    // user management
    @Required private(set) var currentUserId: String

    let database: Firestore
    let userManager: ChatFirestoreUserManager<UserFirestore>?
    let mediaUploader: MediaUploading

    private var listeners: [Listener: ListenerRegistration] = [:]
    private var messagesPaginators: [EntityIdentifier: Pagination<MessageFirestore>] = [:]
    private var conversationsPagination: Pagination<ConversationFirestore> = .empty

    // dedicated thread queue
    let networkingQueue = DispatchQueue(label: "com.strv.chat.networking.firestore", qos: .userInteractive)

    public required init(config: ChatFirestoreConfig, userManager: UserManager?, mediaUploader: MediaUploading = ChatFirestoreMediaUploader(), decoder: JSONDecoder = JSONDecoder.chatDefault) {

        // setup from config
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }
        
        let app: FirebaseApp?
        
        if let existingInstance = FirebaseApp.app() {
            app = existingInstance
        } else {
            let appName = UUID().uuidString
            FirebaseApp.configure(name: appName, options: options)
            app = FirebaseApp.app(name: appName)
        }
        
        guard let firebaseApp = app else {
            fatalError("Can't configure Firebase")
        }
        
        // Pass firebase app reference to `ChatFirestoreMediaUploader`
        if let uploader = mediaUploader as? ChatFirestoreMediaUploader {
            uploader.firebaseApp = firebaseApp
        }

        self.config = config
        self.decoder = decoder
        self.database = Firestore.firestore(app: firebaseApp)
        self.userManager = userManager
        self.mediaUploader = mediaUploader
    }
    
    /// Convenience initializer
    /// WARNING: This initializer instantiates `ChatFirestoreDefaultUserManager` as a user manager. If you want to use custom user mananager or you don't want to use separate user manager at all, use the full initializer with `userManager` parameter
    ///
    /// - Parameters:
    ///   - config: Networking configuration
    ///   - mediaUploader: Service for uploading photos, videos and other media
    ///   - decoder: Instance of `JSONDecoder ` if you don't want to use the default one
    public convenience init(config: ChatFirestoreConfig, mediaUploader: MediaUploading = ChatFirestoreMediaUploader(), decoder: JSONDecoder = JSONDecoder.chatDefault) {
        let userManager = ChatFirestoreDefaultUserManager<UserFirestore>(config: config, decoder: decoder)
        
        self.init(config: config, userManager: userManager, mediaUploader: mediaUploader, decoder: decoder)
    }
    
    deinit {
        logger.log("\(self) released", level: .debug)
        listeners.forEach {
            stop(listener: $0.key)
        }
    }
}

// MARK: - User management
public extension ChatFirestore {
    func setCurrentUser(user id: EntityIdentifier) {
        networkingQueue.async { [weak self] in
            self?.currentUserId = id
        }
    }
}

// MARK: - Load
public extension ChatFirestore {
    func load(completion: @escaping (Result<Void, ChatError>) -> Void) {
        completion(.success(()))
    }
}

// MARK: Listen to collections
public extension ChatFirestore {
    func listenToConversation(conversation id: EntityIdentifier, completion: @escaping (Result<ConversationFirestore, ChatError>) -> Void) {
        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            let listener = Listener.conversation(conversationId: id)
            let reference = self.database
                .collection(self.constants.conversations.path)
                .document(id)

            self.listenToDocument(reference: reference, listener: listener, completion: { (result: Result<ConversationFirestore, ChatError>) in
                
                guard case let .success(conversation) = result else {
                    completion(result)
                    return
                }
                
                guard let userManager = self.userManager else {
                    completion(result)
                    return
                }

                self.loadUsersForConversations(conversations: [conversation], userManager: userManager) { result in
                    switch result {
                    case .success(let conversations):
                        if let conversation = conversations.first {
                            completion(.success(conversation))
                        } else {
                            completion(.failure(.unexpectedState))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            })
        }
    }

    func listenToConversations(pageSize: Int, completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let listener = Listener.conversationList(pageSize: pageSize)

            self.conversationsPagination = Pagination(
                updateBlock: completion,
                listener: listener,
                pageSize: pageSize
            )

            let query = self.conversationsQuery(numberOfConversations: self.conversationsPagination.itemsLoaded)

            self.listenToCollection(query: query, listener: listener, completion: { (result: Result<[ConversationFirestore], ChatError>) in

                guard case let .success(conversations) = result else {
                    completion(result)
                    return
                }

                if let userManager = self.userManager {
                    self.loadUsersForConversations(conversations: conversations, userManager: userManager, completion: completion)
                } else {
                    completion(.success(conversations))
                }
            })
        }
    }

    func listenToMessages(conversation id: EntityIdentifier, pageSize: Int, completion: @escaping (Result<[MessageFirestore], ChatError>) -> Void) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            let completion = self.reversedDataCompletion(completion: completion)
            let listener = Listener.messages(pageSize: pageSize, conversationId: id)
            let query = self.messagesQuery(conversation: id, numberOfMessages: pageSize)

            self.listenToCollection(query: query, listener: listener, completion: completion)

            self.messagesPaginators[id] = Pagination(
                updateBlock: completion,
                listener: listener,
                pageSize: pageSize
            )
        }
    }

    func remove(listener: Listener) {
        networkingQueue.async { [weak self] in
            self?.stop(listener: listener)
        }
    }
    
    func loadMoreConversations() {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            self.conversationsPagination = self.advancePaginator(
                paginator: self.conversationsPagination,
                query: self.conversationsQuery(),
                listenerCompletion: { [weak self] result in
                    guard let self = self else {
                        return
                    }

                    guard let completion = self.conversationsPagination.updateBlock else {
                        logger.log("Unexpected error, conversation pagination \(self.conversationsPagination) update block is nil", level: .debug)
                        return
                    }

                    switch result {
                    case .success(let conversations):
                        if let userManager = self.userManager {
                            self.loadUsersForConversations(conversations: conversations, userManager: userManager, completion: completion)
                        } else {
                            completion(.success(conversations))
                        }
                    case .failure(let error):
                        completion(.failure(error))
                    }
            })
        }
    }
    
    func loadMoreMessages(conversation id: String) {

        networkingQueue.async { [weak self] in
            guard let self = self else {
                return
            }

            guard let paginator = self.messagesPaginators[id] else {
                return
            }

            let query = self.messagesQuery(
                conversation: id,
                numberOfMessages: paginator.itemsLoaded
            )

            self.messagesPaginators[id] = self.advancePaginator(
                paginator: paginator,
                query: query,
                listenerCompletion: { (result: Result<[MessageFirestore], ChatError>) in
                    self.messagesPaginators[id]?.updateBlock?(result)
            })
        }
    }
    
    func getMessages(conversation id: EntityIdentifier, request: MessagesRequest, completion: @escaping (Result<[NetworkMessage], ChatError>) -> Void) {
        
        let messagesCollection = database
            .collection(constants.conversations.path)
            .document(id)
            .collection(constants.messages.path)
        
        let anchorMessage = messagesCollection.document(request.messageId)
        
        // We need to get a document snapshot for the message after/before which we will be loading data
        getDocumentSnapshot(document: anchorMessage) { [weak self, decoder] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case let .success(documentSnapshot):
                var query = messagesCollection
                    .limit(to: request.count)
                    .order(by: self.constants.messages.sentAtAttributeName, descending: true)
                
                query = request.direction == .before
                    ? query.end(beforeDocument: documentSnapshot)
                    : query.start(afterDocument: documentSnapshot)
                
                self.getDocuments(query: query, completion: { (result: Result<[NetworkMessage], ChatError>) in
                    switch result {
                    case let .success(messages):
                        var messages = messages
                        
                        if request.includeInResult,
                           let anchorMessage = try? documentSnapshot.decode(to: MessageFirestore.self, with: decoder) {
                            switch request.direction {
                            case .before:
                                messages.append(anchorMessage)
                            case .after:
                                messages.insert(anchorMessage, at: 0)
                            }
                        }
                        
                        completion(.success(messages))
                    case let .failure(error):
                        completion(.failure(error))
                    }
                })
            case let .failure(error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: Queries
extension ChatFirestore {
    func conversationsQuery(numberOfConversations: Int? = nil) -> Query {
        let lastMessageTimestampFieldPath = FieldPath([
            constants.conversations.lastMessageAttributeName,
            constants.messages.sentAtAttributeName
        ])
        
        let query = database
            .collection(constants.conversations.path)
            .whereField(constants.conversations.membersAttributeName, arrayContains: currentUserId)
            .order(by: lastMessageTimestampFieldPath, descending: true)

        if let limit = numberOfConversations {
            return query.limit(to: limit)
        }
        
        return query
    }
    
    func messagesQuery(conversation id: String, numberOfMessages: Int?) -> Query {
        let query = database
            .collection(constants.conversations.path)
            .document(id)
            .collection(constants.messages.path)
            .order(by: constants.messages.sentAtAttributeName, descending: true)
        
        if let limit = numberOfMessages {
            return query.limit(to: limit)
        }
        
        return query
    }
}

// MARK: Private methods
extension ChatFirestore {
    func getDocumentSnapshot(document: DocumentReference, completion: @escaping (Result<DocumentSnapshot, ChatError>) -> Void) {
        document.getDocument { [weak self, decoder] (snapshot, error) in
            self?.networkingQueue.async {
                if let snapshot = snapshot {
                    completion(.success(snapshot))
                } else if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    completion(.failure(.internal(message: "Unknown")))
                }
            }
        }
    }
    
    func getDocuments<T: Decodable>(query: Query, completion: @escaping (Result<[T], ChatError>) -> Void) {
        query.getDocuments { [weak self, decoder] (documentsSnapshot, error) in
            self?.networkingQueue.async {
                if let documentsSnapshot = documentsSnapshot {
                    var list: [T]
                    
                    do {
                        list = try documentsSnapshot.documents.compactMap {
                            try $0.decode(to: T.self, with: decoder)
                        }
                        
                    } catch {
                        logger.log("Couldn't decode document: \(error)", level: .info)
                        return
                    }
                    
                    completion(.success(list))
                } else if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    completion(.failure(.internal(message: "Unknown")))
                }
            }
        }
    }
    
    func listenToCollection<T: Decodable>(query: Query, listener: Listener, completion: @escaping (Result<[T], ChatError>) -> Void) {
        let networkListener = query.addSnapshotListener(includeMetadataChanges: false) { [weak self, decoder] (snapshot, error) in
            self?.networkingQueue.async {
                if let snapshot = snapshot {
                    let list: [T] = snapshot.documents.compactMap {
                        do {
                            return try $0.decode(to: T.self, with: decoder)
                        } catch {
                            logger.log("Couldn't decode document: \(error)", level: .info)
                            return nil
                        }
                    }
                    completion(.success(list))
                } else if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    completion(.failure(.internal(message: "Unknown")))
                }
            }
        }
        
        listeners[listener] = networkListener
    }
    
    func stop(listener: Listener) {
        listeners[listener]?.remove()
        listeners[listener] = nil
    }

    func listenToDocument<T: Decodable>(reference: DocumentReference, listener: Listener, completion: @escaping (Result<T, ChatError>) -> Void) {
        let networkListener = reference.addSnapshotListener { [weak self, decoder] (snapshot, error) in
            self?.networkingQueue.async {
                if let snapshot = snapshot {
                    do {
                        let object = try snapshot.decode(to: T.self, with: decoder)
                        completion(.success(object))
                    } catch {
                        completion(.failure(.internal(message: "Couldn't decode document: \(error)")))
                    }
                } else if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    completion(.failure(.internal(message: "Unknown")))
                }
            }
        }

        listeners[listener] = networkListener
    }

    func conversationsWithMembers(conversations: [ConversationFirestore], users: [UserFirestore]) -> [ConversationFirestore] {
        conversations.map { conversation in
            var result = conversation
            result.members = users.filter { result.memberIds.contains($0.id) }
            return result
        }
    }

    func advancePaginator<T: Decodable>(paginator: Pagination<T>, query: Query, listenerCompletion: @escaping (Result<[T], ChatError>) -> Void) -> Pagination<T> {
        
        var paginator = paginator
        
        stop(listener: paginator.listener)
        
        paginator.nextPage()
        
        let query = query.limit(to: paginator.itemsLoaded)
        
        listenToCollection(query: query, listener: paginator.listener, completion: listenerCompletion)
        
        return paginator
    }
    
    func reversedDataCompletion<T: Decodable>(completion: @escaping (Result<[T], ChatError>) -> Void) -> (Result<[T], ChatError>) -> Void {
        return { result in
            switch result {
            case .success(let data):
                completion(.success(data.reversed()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func loadUsersForConversations(conversations: [ConversationFirestore], userManager: UserManager, completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {
        userManager.users(userIds: conversations.flatMap { $0.memberIds }) { [weak self] result in
            guard let self = self else {
                return
            }
            self.networkingQueue.async {
                switch result {
                case .success(let users):
                    // Set members from previously downloaded users
                    completion(.success(self.conversationsWithMembers(conversations: conversations, users: users)))
                case .failure(let error):
                    logger.log("Load users for conversations failed: \(error)", level: .debug)
                    completion(.failure(error))
                }
            }
        }
    }
}
