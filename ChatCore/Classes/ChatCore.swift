//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

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
    private var dataManagers = [ListenerArguments: DataManager]()
    
    private var conversationListeners = [
        ListenerArguments: [IdentifiableClosure<ConversationResult, Void>]
    ]()
    
    private var messagesListeners = [
        ListenerArguments: [IdentifiableClosure<MessagesResult, Void>]
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

    deinit {
        print("\(self) released")
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    public required init (networking: Networking) {
        self.networking = networking
        self.networking.didFinishedLoading = { [weak self] result in
            self?.didFinishLoading(result: result)
        }
    }
}

// MARK: Sending messages
extension ChatCore {

    open func send(message: MessageSpecifyingUI, to conversation: ObjectIdentifier,
                   completion: @escaping (Result<MessageUI, ChatError>) -> Void) {

        taskManager.run(attributes: [.backgroundTask, .afterInit, .backgroundThread]) { [weak self] taskCompletion in
            let mess = Networking.MS(uiModel: message)
            self?.networking.send(message: mess, to: conversation) { result in
                // clean up closure from background task
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

// MARK: Seen flag
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

// MARK: Listening to updates
extension ChatCore {
    open func listenToConversations(
        pageSize: Int,
        completion: @escaping (ConversationResult) -> Void
    ) -> ObjectIdentifier {
        
        let closure = IdentifiableClosure<ConversationResult, Void>(completion)
        
        let arguments = ListenerArguments.conversations(pageSize: pageSize)
        
        // Add completion block
        if conversationListeners[arguments] == nil {
            conversationListeners[arguments] = []
        }
        conversationListeners[arguments]?.append(closure)
        
        if let existingListeners = conversationListeners[arguments], existingListeners.count > 1 {
            // A firebase listener for these arguments has already been registered, no need to register again
            return closure.id
        }
        
        dataManagers[arguments] = DataManager(pageSize: pageSize)

        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToConversations(pageSize: pageSize) { result in
                switch result {
                case .success(let conversations):
                    
                    self.dataManagers[arguments]?.update(data: conversations)
                    let converted = conversations.compactMap({ $0.uiModel })
                    
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[arguments]?.reachedEnd ?? true)
                    
                    self.conversations = data
                    taskCompletion(.success)
                    
                    // Call each closure registered for these arguments
                    self.conversationListeners[arguments]?.forEach {
                        $0.closure(.success(data))
                    }
                case .failure(let error):
                    taskCompletion(.failure(error))
                    self.conversationListeners[arguments]?.forEach {
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
    ) -> ObjectIdentifier {
        
        let closure = IdentifiableClosure<MessagesResult, Void>(completion)
        
        let arguments = ListenerArguments.messages(pageSize: pageSize, conversationId: id)
        
        if messagesListeners[arguments] == nil {
            messagesListeners[arguments] = []
        }
        
        messagesListeners[arguments]?.append(closure)
        
        if let existingListeners = conversationListeners[arguments], existingListeners.count > 1 {
            // A firebase listener for these arguments has already been registered, no need to register again
            return closure.id
        }
        
        dataManagers[arguments] = DataManager(pageSize: pageSize)
        
        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToMessages(conversation: id, pageSize: pageSize) { result in
                switch result {
                case .success(let messages):
                    
                    self.dataManagers[arguments]?.update(data: messages)
                    
                    let converted = messages.compactMap({ $0.uiModel })
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[arguments]?.reachedEnd ?? true)
                    
                    self.messages[id] = data
                    taskCompletion(.success)
                    
                    // Call each closure registered for these arguments
                    self.messagesListeners[arguments]?.forEach {
                        $0.closure(.success(data))
                    }
                case .failure(let error):
                    taskCompletion(.failure(error))
                    self.messagesListeners[arguments]?.forEach {
                        $0.closure(.failure(error))
                    }
                }
            }})

        return closure.id
    }
    
    open func loadMoreMessages(conversation id: ObjectIdentifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ObjectIdentifier) {
        removeListener(listener, from: &conversationListeners)
        removeListener(listener, from: &messagesListeners)
    }
}

// MARK: ChatNetworkServicing load state observing
private extension ChatCore {
    func didFinishLoading(result: Result<Void, ChatError>) {
        
        switch result {
        case .success:
            self.taskManager.initialized = true
        case .failure(let error):
            print(error)
        }
    }
    
    func removeListener<T>(
        _ listener: ObjectIdentifier,
        from listeners: inout [ListenerArguments: [IdentifiableClosure<T, Void>]]
    ) {
        listeners.forEach { (arguments, closures) in
            closures.forEach { _ in
                listeners[arguments] = listeners[arguments]?.filter { $0.id != listener }
            }
            
            // If there are no more closures registered for this set of arguments, remove networking listener and data manager
            if listeners[arguments]?.isEmpty ?? true {
                networking.remove(arguments: arguments)
                dataManagers[arguments] = nil
            }
        }
    }
}
