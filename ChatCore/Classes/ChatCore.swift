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
    
    // swiftlint:disable type_name
    public typealias C = Models.CUI
    public typealias MS = Models.MSUI
    public typealias M = Models.MUI
    public typealias USR = Models.USRUI

    let networking: Networking

    public var currentUser: USR? {
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
    }
}
    
// MARK: Sending messages
extension ChatCore {
    open func send(message: MS, to conversation: ChatIdentifier,
                   completion: @escaping (Result<M, ChatError>) -> Void) {
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
    open func updateSeenMessage(_ message: M, in conversation: ChatIdentifier) {
        let seenMessage = Networking.M(uiModel: message)
        networking.updateSeenMessage(seenMessage, in: conversation)
    }
}

// MARK: Listening to updates
extension ChatCore {
    open func listenToConversations(pageSize: Int, completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener {
        let listener = networking.listenToConversations(pageSize: pageSize) { result in
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
    
    open func loadMoreConversations() {
        networking.loadMoreConversations()
    }

    open func listenToMessages(
        conversation id: ChatIdentifier,
        pageSize: Int,
        completion: @escaping (Result<[M], ChatError>) -> Void
    ) -> ChatListener {
        let listener = networking.listenToMessages(conversation: id, pageSize: pageSize) { result in
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
    
    open func loadMoreMessages(conversation id: ChatIdentifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ChatListener) {
        networking.remove(listener: listener)
    }
}
