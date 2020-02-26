//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

open class ChatCore<Networking: ChatNetworkServicing, Models: ChatUIModels>: ChatCoreServicing
           where Networking.C: ChatUIConvertible, Networking.M: ChatUIConvertible, Networking.MS: ChatUIConvertible,
            Networking.U: ChatUIConvertible, Networking.C.User.ChatUIModel == Models.USRUI,
            Networking.C.ChatUIModel == Models.CUI, Networking.C.Message.ChatUIModel == Models.MUI,
            Networking.MS.ChatUIModel == Models.MSUI {

    public typealias Networking = Networking
    public typealias UIModels = Models
    
    public typealias ConversationUI = Models.CUI
    public typealias MessageSpecifyingUI = Models.MSUI
    public typealias MessageUI = Models.MUI
    public typealias UserUI = Models.USRUI
    
    private var dataManagers = [ListenerIdentifier: DataManager]()

    private var networking: Networking
    private var cachedCalls = [() -> Void]()
    private var initialized = false
    
    private var messages = [Identifier: DataPayload<[MessageUI]>]()
    private var conversations = DataPayload(data: [ConversationUI](), reachedEnd: false)

    public var currentUser: UserUI? {
        guard let currentUser = networking.currentUser else {
            return nil
        }
        return currentUser.uiModel
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    public required init (networking: Networking) {
        self.networking = networking
        self.networking.delegate = self
    }
}
    
// MARK: Sending messages
extension ChatCore {
    open func send(message: MessageSpecifyingUI, to conversation: Identifier,
                   completion: @escaping (Result<MessageUI, ChatError>) -> Void) {
        runAfterInit { [weak self] in
            let mess = Networking.MS(uiModel: message)
            self?.networking.send(message: mess, to: conversation) { result in
                switch result {
                case .success(let message):
                    completion(.success(message.uiModel))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

// MARK: Seen flag
extension ChatCore {
    open func updateSeenMessage(_ message: MessageUI, in conversation: Identifier) {
        
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
    open func listenToConversations(pageSize: Int, completion: @escaping (Result<DataPayload<[ConversationUI]>, ChatError>) -> Void) -> ListenerIdentifier {
        let listener = ListenerIdentifier.generateIdentifier()
        
        dataManagers[listener] = DataManager(pageSize: pageSize)

        runAfterInit { [weak self] in
            
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
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        return listener
    }
    
    open func loadMoreConversations() {
        networking.loadMoreConversations()
    }

    open func listenToMessages(
        conversation id: Identifier,
        pageSize: Int,
        completion: @escaping (Result<DataPayload<[MessageUI]>, ChatError>) -> Void
    ) -> ListenerIdentifier {
        let listener = ListenerIdentifier.generateIdentifier()

        dataManagers[listener] = DataManager(pageSize: pageSize)
        
        runAfterInit { [weak self] in
            
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
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        return listener
    }
    
    open func loadMoreMessages(conversation id: Identifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ListenerIdentifier) {
        networking.remove(listener: listener)
        dataManagers[listener] = nil
    }
}

// MARK: Private methods
private extension ChatCore {
    func runAfterInit(closure: @escaping () -> Void) {
        guard initialized else {
            schedule(closure: closure)
            
            return
        }
        
        closure()
    }
    
    func schedule(closure: @escaping () -> Void) {
        cachedCalls.append(closure)
    }
}

// MARK: ChatNetworkServicingDelegate
extension ChatCore: ChatNetworkServicingDelegate {
    public func didFinishLoading(result: Result<Void, ChatError>) {
        
        switch result {
        case .success:
            initialized = true
            
            cachedCalls.forEach { call in
                call()
            }
            
            cachedCalls = []
        case .failure(let error):
            print(error)
        }
    }
}
