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
    
    public typealias C = Models.CUI
    public typealias MS = Models.MSUI
    public typealias M = Models.MUI
    public typealias USR = Models.USRUI

    let networking: Networking

    public var currentUser: USR? {
        get {
            guard let currentUser = networking.currentUser else { return nil }
            return currentUser.uiModel
        }
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    required public init (networking: Networking) {
        self.networking = networking
    }
}
    
// MARK: Sending messages
extension ChatCore {
    open func send(message: MS, to conversation: ChatIdentifier,
                   completion: @escaping (Result<M, ChatError>) -> Void) {

        // FIXME: Solve without explicit type casting
        let mess = Networking.MS(uiModel: message)
        networking.send(message: mess, to: conversation) { result in
            switch result {
            case .success(let message):
                completion(.success( message.uiModel))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// MARK: Seen flag
extension ChatCore {
    open func markAsSeen(message: M) {
        // TODO: Implement
    }
}

// MARK: Listening to updates
extension ChatCore {
    open func listenToConversations(completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener {

        // FIXME: Solve without explicit type casting
        let listener = networking.listenToConversations() { result in
            switch result {
            case .success(let conversations):
                let converted = conversations.compactMap({ $0.uiModel })
                completion(.success(converted))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return listener
    }

    open func listenToConversation(with id: ChatIdentifier,
                                   completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener {

        // FIXME: Solve without explicit type casting
        let listener = networking.listenToConversation(with: id) { result in
                   switch result {
                   case .success(let messages):
                    let converted = messages.compactMap({ $0.uiModel })
                       completion(.success(converted))
                   case .failure(let error):
                       completion(.failure(error))
                   }
               }
        return listener
    }
    
    open func remove(listener: ChatListener) {
        networking.remove(listener: listener)
    }
}

// MARK: - Loading data
extension ChatCore {
    
    open func loadMessages(conversation id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void, updatesListener: ((Result<M, ChatError>) -> Void)?) {
        
        networking.loadMessages(conversation: id) { [weak self] result in
            
            switch result {
            case .success(let messages):
                completion(.success(messages.compactMap({ $0.uiModel })))
                
                guard let updatesListener = updatesListener else {
                    return
                }
                
                // start listening to the conversation after the first successful load
                self?.networking.listenToConversation(with: id, completion: { result in
                    switch result {
                    case .success(let messages):
                        guard let newMessage = messages.first else {
                            return
                        }
                        
                        updatesListener(.success(newMessage.uiModel))
                    case .failure(let error):
                        updatesListener(.failure(error))
                    }
                })
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    open func loadMoreMessages(conversation id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) {
        networking.loadMoreMessages(conversation: id) { result in
            switch result {
            case .success(let messages):
                completion(.success(messages.compactMap({ $0.uiModel })))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    open func loadConversations(completion: @escaping (Result<[C], ChatError>) -> Void, updatesListener: ((Result<C, ChatError>) -> Void)?) {
        
        networking.loadConversations { [weak self] result in
            
            switch result {
            case .success(let conversations):
                let converted = conversations.compactMap({ $0.uiModel })
                completion(.success(converted))
                
                guard let updatesListener = updatesListener else {
                    return
                }
                
                self?.networking.listenToConversations { result in

                    switch result {
                    case .success(let conversations):
                        guard let newConversation = conversations.first else {
                            return
                        }
                        
                        updatesListener(.success(newConversation.uiModel))
                    case .failure(let error):
                        updatesListener(.failure(error))
                    }
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    open func loadMoreConversations(completion: @escaping (Result<[C], ChatError>) -> Void) {
        networking.loadMoreConversations { result in
            switch result {
            case .success(let conversations):
                completion(.success(conversations.compactMap({ $0.uiModel })))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}
