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
    open func updateSeenMessage(_ message: M, to conversation: ChatIdentifier) {
        let seenMessage = Networking.M(uiModel: message)
        networking.updateSeenMessage(seenMessage, to: conversation)
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
