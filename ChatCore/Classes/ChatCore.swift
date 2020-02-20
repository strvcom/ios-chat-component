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

    private var networking: Networking
    private var cachedCalls = [() -> Void]()
    private var initialized = false

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
    open func send(message: MessageSpecifyingUI, to conversation: ChatIdentifier,
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
    open func updateSeenMessage(_ message: MessageUI, in conversation: ChatIdentifier) {
        let seenMessage = Networking.M(uiModel: message)
        networking.updateSeenMessage(seenMessage, in: conversation)
    }
}

// MARK: Listening to updates
extension ChatCore {
    open func listenToConversations(pageSize: Int, completion: @escaping (Result<[ConversationUI], ChatError>) -> Void) -> ChatListener {
        let listener = ChatListener.generateIdentifier()

        runAfterInit { [weak self] in
            self?.networking.listenToConversations(pageSize: pageSize, listener: listener) { result in
                switch result {
                case .success(let conversations):
                    let converted = conversations.compactMap({ $0.uiModel })
                    completion(.success(converted))
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
        conversation id: ChatIdentifier,
        pageSize: Int,
        completion: @escaping (Result<[MessageUI], ChatError>) -> Void
    ) -> ChatListener {
        let listener = ChatListener.generateIdentifier()
        
        runAfterInit { [weak self] in
            self?.networking.listenToMessages(conversation: id, pageSize: pageSize, listener: listener) { result in
                switch result {
                case .success(let messages):
                    let converted = messages.compactMap({ $0.uiModel })
                    completion(.success(converted))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        return listener
    }
    
    open func loadMoreMessages(conversation id: ChatIdentifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ChatListener) {
        networking.remove(listener: listener)
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
