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

    private lazy var taskManager = TaskManager()
    private lazy var keychainManager = KeychainManager()
    private var dataManagers = [ListenerIdentifier: DataManager]()

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
        NotificationCenter.default.removeObserver(self)
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    public required init (networking: Networking) {
        self.networking = networking
        self.networking.didFinishedLoading = { [weak self] result in
            self?.didFinishLoading(result: result)
        }

        // Observer for app activation to resend all stored messages
        NotificationCenter.default.addObserver(self, selector: #selector(resendMessages), name: .appDidBecomeActive, object: nil)
    }

    // MARK: - Resend stored messages
    @objc private func resendMessages() {
        let messages: [Message<MessageSpecifyingUI>] = keychainManager.unsentMessages()
        messages.forEach { send(message: $0.content, to: $0.conversationId) { [weak self] result in
            if case .failure = result {
                self?.keychainManager.storeUnsentMessage($0)
            }
        }}
    }
}

// MARK: - Sending messages
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
                    // FIXME: CJ Until full tasks logic is implemented store when error
                    let messageCache = Message(content: message, conversationId: conversation)
                    self?.keychainManager.storeUnsentMessage(messageCache)
                    taskCompletion(.failure(error))
                    completion(.failure(error))
                }
            }
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
    open func listenToConversations(pageSize: Int, completion: @escaping (Result<DataPayload<[ConversationUI]>, ChatError>) -> Void) -> ListenerIdentifier {
        let listener = ListenerIdentifier.generateIdentifier()
        
        dataManagers[listener] = DataManager(pageSize: pageSize)

        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToConversations(pageSize: pageSize, listener: listener) { result in
                switch result {
                case .success(let conversations):
                    
                    self.dataManagers[listener]?.update(data: conversations)
                    let converted = conversations.compactMap({ $0.uiModel })
                    
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    
                    self.conversations = data
                    taskCompletion(.success)
                    completion(.success(data))
                case .failure(let error):
                    taskCompletion(.failure(error))
                    completion(.failure(error))
                }
            }})

        return listener
    }
    
    open func loadMoreConversations() {
        networking.loadMoreConversations()
    }

    open func listenToMessages(
        conversation id: ObjectIdentifier,
        pageSize: Int,
        completion: @escaping (Result<DataPayload<[MessageUI]>, ChatError>) -> Void
    ) -> ListenerIdentifier {
        let listener = ListenerIdentifier.generateIdentifier()

        dataManagers[listener] = DataManager(pageSize: pageSize)
        
        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToMessages(conversation: id, pageSize: pageSize, listener: listener) { result in
                switch result {
                case .success(let messages):
                    
                    self.dataManagers[listener]?.update(data: messages)
                    
                    let converted = messages.compactMap({ $0.uiModel })
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    
                    self.messages[id] = data
                    taskCompletion(.success)
                    completion(.success(data))
                case .failure(let error):
                    taskCompletion(.failure(error))
                    completion(.failure(error))
                }
            }})

        return listener
    }
    
    open func loadMoreMessages(conversation id: ObjectIdentifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ListenerIdentifier) {
        networking.remove(listener: listener)
        dataManagers[listener] = nil
    }
}

// MARK: - ChatNetworkServicing load state observing
private extension ChatCore {
    func didFinishLoading(result: Result<Void, ChatError>) {
        
        switch result {
        case .success:
            self.taskManager.initialized = true
        case .failure(let error):
            print(error)
        }
    }
}
