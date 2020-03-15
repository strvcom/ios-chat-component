//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import UIKit

open class ChatCore<Networking: ChatNetworkServicing, Models: ChatUIModels>: ChatCoreServicing where
    
    // Specify that associated types
    // Conversation, Message (receive), MessageSpecifying (send) and User
    // of ChatNetworkServicing have to conform to `ChatUIConvertible`
    Networking.C: ChatUIConvertible,
    Networking.M: ChatUIConvertible,
    Networking.MS: ChatUIConvertible,
    Networking.U: ChatUIConvertible,
    
    Networking.U.ChatUIModel == Models.USRUI,
    Networking.C.ChatUIModel == Models.CUI,
    Networking.M.ChatUIModel == Models.MUI,
    Networking.MS.ChatUIModel == Models.MSUI {

    public typealias Networking = Networking
    public typealias UIModels = Models
    
    public typealias ConversationUI = Models.CUI
    public typealias MessageSpecifyingUI = Models.MSUI
    public typealias MessageUI = Models.MUI
    public typealias UserUI = Models.USRUI
    
    public typealias ConversationResult = Result<DataPayload<[ConversationUI]>, ChatError>
    public typealias MessagesResult = Result<DataPayload<[MessageUI]>, ChatError>

    private lazy var taskManager = TaskManager()
    private lazy var keychainManager = KeychainManager()

    private var dataManagers = [Listener: DataManager]()
    
    private var conversationListeners = [
        Listener: [IdentifiableClosure<ConversationResult, Void>]
    ]()
    
    private var messagesListeners = [
        Listener: [IdentifiableClosure<MessagesResult, Void>]
    ]()
    
    private var networking: Networking
    
    private var messages = [ObjectIdentifier: DataPayload<[MessageUI]>]()
    private var conversations = DataPayload(data: [ConversationUI](), reachedEnd: false)

    public var currentUser: UserUI? {
        guard let currentUser = networking.currentUser else {
            return nil
        }
        return currentUser.uiModel
    }

    // current state observing
    public private(set) var currentState: ChatCoreState {
        didSet {
            stateChanged?(currentState)
        }
    }
    public var stateChanged: ((ChatCoreState) -> Void)?

    deinit {
        print("\(self) released")
        NotificationCenter.default.removeObserver(self)
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    public required init (networking: Networking) {
        currentState = .connecting
        self.networking = networking
        loadNetworkService()

        // hook to app did become active to resend messages
        NotificationCenter.default.addObserver(self, selector: #selector(resendUnsentMessages), name: UIApplication.didBecomeActiveNotification, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(resendUnsentMessages), name: UIScene.didActivateNotification, object: nil)
        }
    }

    // Needs to be in main class scope bc Extensions of generic classes cannot contain '@objc' members
    @objc open func resendUnsentMessages() {
        let messages: [CachedMessage<MessageSpecifyingUI>] = keychainManager.unsentMessages()
        messages.forEach { message in
            keychainManager.removeMessage(message: message)
            send(message: message.content, to: message.conversationId, completion: { _ in })
        }
    }
}

// MARK: - Sending messages
extension ChatCore {

    open func send(message: MessageSpecifyingUI, to conversation: ObjectIdentifier,
                   completion: @escaping (Result<MessageUI, ChatError>) -> Void) {

        let cachedMessage = cacheMessage(message: message, from: conversation)

        taskManager.run(attributes: [.backgroundTask, .afterInit, .backgroundThread, .retry(.finite())]) { [weak self] taskCompletion in
            let mess = Networking.MS(uiModel: message)
            self?.networking.send(message: mess, to: conversation) { result in
                self?.handleResultInCache(cachedMessage: cachedMessage, result: result)
                switch result {
                case .success(let message):
                    taskCompletion(.success)
                    completion(.success(message.uiModel))

                case .failure(let error):

                    taskCompletion(.failure(error))
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: - Caching messages
private extension ChatCore {
    func cacheMessage<T: MessageSpecifying & Cachable>(message: T, from conversation: ObjectIdentifier) -> CachedMessage<T> {
        // store to keychain for purpose message wont send
        let cachedMessage = CachedMessage(content: message, conversationId: conversation)
        keychainManager.storeUnsentMessage(cachedMessage)

        return cachedMessage
    }

    func handleResultInCache<T: MessageSpecifying & Cachable, U: MessageRepresenting>(cachedMessage: CachedMessage<T>, result: Result<U, ChatError>) {
        // if other than network error remove from cache
        guard case .failure(let error) = result, case .networking = error else {
            keychainManager.removeMessage(message: cachedMessage)
            return
        }
    }
}

// MARK: - Seen flag
extension ChatCore {
    open func updateSeenMessage(_ message: MessageUI, in conversation: ObjectIdentifier) {
        
        guard let existingConversation = conversations.data.first(where: { conversation == $0.id }) else {
            print("Conversation with id \(conversation) not found")
            return
        }
        
        let seenMessage = Networking.M(uiModel: message)
        let conversation = Networking.C(uiModel: existingConversation)
        
        networking.updateSeenMessage(seenMessage, in: conversation)
    }
}

// MARK: - Listening to updates
extension ChatCore {
    open func listenToConversations(
        pageSize: Int,
        completion: @escaping (ConversationResult) -> Void
    ) -> ListenerIdentifier {
        
        let closure = IdentifiableClosure<ConversationResult, Void>(completion)
        let listener = Listener.conversations(pageSize: pageSize)
        
        // Add completion block
        if conversationListeners[listener] == nil {
            conversationListeners[listener] = []
        }
        conversationListeners[listener]?.append(closure)
        
        if let existingListeners = conversationListeners[listener], existingListeners.count > 1 {
            // A firebase listener for these arguments has already been registered, no need to register again
            return closure.id
        }
        
        dataManagers[listener] = DataManager(pageSize: pageSize)

        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToConversations(pageSize: pageSize) { result in
                switch result {
                case .success(let conversations):
                    
                    self.dataManagers[listener]?.update(data: conversations)
                    let converted = conversations.compactMap({ $0.uiModel })
                    
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    
                    self.conversations = data
                    taskCompletion(.success)
                    
                    // Call each closure registered for this listener
                    self.conversationListeners[listener]?.forEach {
                        $0.closure(.success(data))
                    }
                case .failure(let error):
                    taskCompletion(.failure(error))
                    self.conversationListeners[listener]?.forEach {
                        $0.closure(.failure(error))
                    }
                }
            }
        })

        return closure.id
    }
    
    open func loadMoreConversations() {
        networking.loadMoreConversations()
    }

    open func listenToMessages(
        conversation id: ObjectIdentifier,
        pageSize: Int,
        completion: @escaping (MessagesResult) -> Void
    ) -> ListenerIdentifier {
        
        let closure = IdentifiableClosure<MessagesResult, Void>(completion)
        let listener = Listener.messages(pageSize: pageSize, conversationId: id)
        
        if messagesListeners[listener] == nil {
            messagesListeners[listener] = []
        }
        
        messagesListeners[listener]?.append(closure)
        
        if let existingListeners = conversationListeners[listener], existingListeners.count > 1 {
            // A firebase listener for these arguments has already been registered, no need to register again
            return closure.id
        }
        
        dataManagers[listener] = DataManager(pageSize: pageSize)
        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToMessages(conversation: id, pageSize: pageSize) { result in
                switch result {
                case .success(let messages):
                    
                    self.dataManagers[listener]?.update(data: messages)
                    
                    let converted = messages.compactMap({ $0.uiModel })
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    
                    self.messages[id] = data
                    taskCompletion(.success)
                    
                    // Call each closure registered for this listener
                    self.messagesListeners[listener]?.forEach {
                        $0.closure(.success(data))
                    }
                case .failure(let error):
                    taskCompletion(.failure(error))
                    self.messagesListeners[listener]?.forEach {
                        $0.closure(.failure(error))
                    }
                }
            }})

        return closure.id
    }
    
    open func loadMoreMessages(conversation id: ObjectIdentifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ListenerIdentifier) {
        removeListener(listener, from: &conversationListeners)
        removeListener(listener, from: &messagesListeners)
    }
}

// MARK: - ChatNetworkServicing load state observing
private extension ChatCore {
    func loadNetworkService() {
        taskManager.run(attributes: [.retry(.infinite), .backgroundThread], { [weak self] taskCompletion in
            self?.networking.load(completion: { [weak self] result in
                switch result {
                case .success:
                    self?.currentState = .connected
                    self?.taskManager.initialized = true
                    taskCompletion(.success)
                case .failure(let error):
                    taskCompletion(.failure(error))
                }
            })
        })
    }
    
    func removeListener<T>(
        _ listenerId: ListenerIdentifier,
        from listeners: inout [Listener: [IdentifiableClosure<T, Void>]]
    ) {
        listeners.forEach { (listener, closures) in
            closures.forEach { _ in
                listeners[listener] = listeners[listener]?.filter { $0.id != listenerId }
            }
            
            // If there are no more closures registered for this set of arguments, remove networking listener and data manager
            if listeners[listener]?.isEmpty ?? true {
                networking.remove(listener: listener)
                dataManagers[listener] = nil
            }
        }
    }
}

// MARK: - Continue stored background tasks
public extension ChatCore {
     func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        taskManager.runBackgroundCalls(completion: completion)
    }
}
