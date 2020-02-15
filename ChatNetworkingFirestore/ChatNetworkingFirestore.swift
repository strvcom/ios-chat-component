//
//  ChatNetworkingFirebase.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestore
import FirebaseCore

public class ChatNetworkFirebase: ChatNetworkServicing {
    public struct Configuration {
        let configUrl: String
        let userId: String

        public init(configUrl: String, userId: String) {
            self.userId = userId
            self.configUrl = configUrl
        }
    }
    
    let database: Firestore

    public private(set) var currentUser: UserFirestore?
    public var delegate: ChatNetworkServicingDelegate?
    
    private var listeners: [ChatListener: ListenerRegistration] = [:]
    private var currentUserId: String?
    private var users: [UserFirestore] = [] {
        didSet {
            if let currentUserId = currentUserId {
                currentUser = users.first{ $0.id == currentUserId }
            }
        }
    }
    
    private var messagesPaginators: [ChatIdentifier: Pagination<MessageFirestore>] = [:]
    private var conversationsPagination: Pagination<ConversationFirestore>?
    
    required public init(config: Configuration) {
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }

        currentUserId = config.userId
        FirebaseApp.configure(options: options)
        
        self.database = Firestore.firestore()
        
        // FIXME: Remove this temporary code when UI for conversation creating is ready
        NotificationCenter.default.addObserver(self, selector: #selector(createTestConversation), name: NSNotification.Name(rawValue: "TestConversation"), object: nil)
        
        load { [weak self] result in
            self?.delegate?.didFinishLoading()
        }
    }
    
    deinit {
        listeners.forEach { (listener, _) in
            remove(listener: listener)
        }
    }
}

// FIXME: Remove this temporary method when UI for conversation creating is ready
private extension ChatNetworkFirebase {
    @objc func createTestConversation() {
        database
            .collection(Constants.usersPath)
            .getDocuments { [weak self] (querySnapshot, _) in
                guard
                    let self = self,
                    let querySnapshot = querySnapshot,
                    let users = try? querySnapshot.documents.compactMap({
                        try $0.data(as: UserFirestore.self)
                    }) else {
                        return
                }
                
                self.database
                    .collection(Constants.conversationsPath)
                    .addDocument(data: [
                        "members": users.map { $0.id }
                    ])
        }
    }
}

// MARK: - Load
public extension ChatNetworkFirebase {
    func load(completion: @escaping (Result<Void, ChatError>) -> Void) {
        listenToUsers { [weak self] (result: Result<[UserFirestore], ChatError>) in
            switch result {
            case let .success(users):
                self?.users = users
                completion(.success(()))
            case let .failure(error):
                completion(.failure(.networking(error: error)))
            }
        }
    }
}

// MARK: Write data
public extension ChatNetworkFirebase {
    func send(message: MessageSpecificationFirestore, to conversation: ChatIdentifier, completion: @escaping (Result<MessageFirestore, ChatError>) -> Void) {
        guard let currentUserId = self.currentUser?.id else {
            completion(.failure(.internal(message: "User not found")))
            return
        }

        message.toJSON { [weak self] result in
            guard let self = self, case let .success(json) = result else {
                if case let .failure(error) = result {
                    completion(.failure(error))
                }
                
                return
            }

            var newJSON: [String : Any] = json
            newJSON[Constants.Message.senderIdAttributeName] = currentUserId
            newJSON[Constants.Message.sentAtAttributeName] = Timestamp()

            let reference = self.database
                .collection(Constants.conversationsPath)
                .document(conversation)
                .collection(Constants.messagesPath)

            let documentRef = reference.document()

            documentRef.setData(newJSON) { error in
                if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    documentRef.getDocument { (documentSnapshot, error) in
                        if let error = error {
                            completion(.failure(.networking(error: error)))
                        } else if let message = try? documentSnapshot?.data(as: MessageFirestore.self) {
                            completion(.success(message))
                        } else {
                            completion(.failure(.unexpectedState))
                        }
                    }
                }
            }
        }
    }

    func updateSeenMessage(_ message: MessageFirestore, in conversation: ChatIdentifier) {
        guard let currentUserId = self.currentUser?.id else {
            print("User not found")
            return
        }
        let reference = self.database
            .collection(Constants.conversationsPath)
            .document(conversation)


        reference.getDocument { (document, _) in
            guard let document = document,
                var conversation = try? document.data(as: ConversationFirestore.self)
                else { return }

            let lastSeenMessage = conversation.seen.first(where: { $0.key == currentUserId })
            guard lastSeenMessage == nil && lastSeenMessage?.value.messageId != message.id else { return }

            conversation.setSeenMessages((messageId: message.id, seenAt: Date()), currentUserId: currentUserId)

            var newJson: [String: Any] = [:]

            for item in conversation.seen {
                let informationJson: [String: Any] = [Constants.Message.messageIdAttributeName: item.value.messageId,
                                                      Constants.Message.timestampAttributeName: item.value.seenAt]
                newJson[item.key] = informationJson
            }

            reference.updateData([Constants.Conversation.seenAttributeName: newJson]) { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
        }
    }
}

// MARK: Listen to collections
public extension ChatNetworkFirebase {
    func listenToConversations(pageSize: Int, listener: ChatListener, completion: @escaping (Result<[ConversationFirestore], ChatError>) -> Void) {
        
        conversationsPagination = Pagination(
            updateBlock: completion,
            listener: listener,
            pageSize: pageSize
        )
        
        let query = conversationsQuery(numberOfConversations: conversationsPagination!.itemsLoaded)
        
        listenTo(query: query, customListener: listener, completion: { [weak self] (result: Result<[ConversationFirestore], ChatError>) in
            
            guard let self = self else {
                return
            }
            
            guard case let .success(conversations) = result else {
                completion(result)
                return
            }

            // Set members from previously downloaded users
            completion(.success(self.conversationsWithMembers(conversations: conversations)))
        })
    }

    func listenToMessages(conversation id: ChatIdentifier, pageSize: Int, listener: ChatListener, completion: @escaping (Result<[MessageFirestore], ChatError>) -> Void) {
        
        let completion = reversedDataCompletion(completion: completion)
        
        let query = messagesQuery(conversation: id, numberOfMessages: pageSize)
        
        listenTo(query: query, customListener: listener, completion: completion)
        
        messagesPaginators[id] = Pagination<MessageFirestore>(
            updateBlock: completion,
            listener: listener,
            pageSize: pageSize
        )
    }
    
    @discardableResult
    func listenToUsers(completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) -> ChatListener {
        let query = database.collection(Constants.usersPath)
        
        return listenTo(query: query, completion: completion)
    }
    
    func remove(listener: ChatListener) {
        listeners[listener]?.remove()
    }
    
    func loadMoreConversations() {
        
        guard let conversationsPagination = conversationsPagination else {
            return
        }
        
        self.conversationsPagination = advancePaginator(
            paginator: conversationsPagination,
            query: conversationsQuery(),
            listenerCompletion: { [weak self] result in
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let conversations):
                    self.conversationsPagination?.updateBlock?(.success(self.conversationsWithMembers(conversations: conversations)))
                case .failure(let error):
                    self.conversationsPagination?.updateBlock?(.failure(error))
                }
        })
    }
    
    func loadMoreMessages(conversation id: String) {
        
        guard var paginator = messagesPaginators[id] else {
            return
        }
        
        let query = messagesQuery(
            conversation: id,
            numberOfMessages: paginator.itemsLoaded
        )
        
        messagesPaginators[id] = advancePaginator(
            paginator: paginator,
            query: query,
            listenerCompletion: { [weak self] (result: Result<[MessageFirestore], ChatError>) in
                self?.messagesPaginators[id]?.updateBlock?(result)
        })
    }
}

// MARK: Queries
private extension ChatNetworkFirebase {
    
    func conversationsQuery(numberOfConversations: Int? = nil) -> Query {
        let query = database
            .collection(Constants.conversationsPath)

        if let limit = numberOfConversations {
            return query.limit(to: limit)
        }
        
        return query
    }
    
    func messagesQuery(conversation id: String, numberOfMessages: Int?) -> Query {
        // FIXME: Make conversations path more generic
        let query = database
            .collection(Constants.conversationsPath)
            .document(id)
            .collection(Constants.messagesPath)
            .order(by: Constants.Message.sentAtAttributeName, descending: true)
        
        if let limit = numberOfMessages {
            return query.limit(to: limit)
        }
        
        return query
    }

}

// MARK: Private methods
private extension ChatNetworkFirebase {
    @discardableResult
    func listenTo<T: Decodable>(query: Query, customListener: ChatListener? = nil, completion: @escaping (Result<[T], ChatError>) -> Void) -> ChatListener {
        let listener = query.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
            if let snapshot = snapshot {
                let list: [T] = snapshot.documents.compactMap {
                    do {
                        return try $0.data(as: T.self)
                    } catch {
                        print("Couldn't decode document:", error)
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
        
        let identifier = customListener ?? ChatListener.generateIdentifier()
        
        listeners[identifier] = listener
        
        return identifier
    }
    
    func conversationsWithMembers(conversations: [ConversationFirestore]) -> [ConversationFirestore] {
        conversations.map { conversation in
            var result = conversation
            result.setMembers(users.filter { result.memberIds.contains($0.id) })
            return result
        }
    }
    
    func advancePaginator<T: Decodable>(paginator: Pagination<T>, query: Query, listenerCompletion: @escaping (Result<[T], ChatError>) -> Void) -> Pagination<T> {
        
        var paginator = paginator
        
        guard let listener = paginator.listener else {
            return paginator
        }
        
        remove(listener: listener)
        
        paginator.nextPage()
        
        let query = query.limit(to: paginator.itemsLoaded)
        
        paginator.listener = listenTo(query: query, customListener: listener, completion: listenerCompletion)
        
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
}
