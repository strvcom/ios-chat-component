//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

open class ChatCore<Converter: ChatModelConverting>: ChatCoreServicing {
    public typealias Networking = Converter.Networking
    public typealias C = Converter.CUI
    public typealias MS = Converter.MSUI
    public typealias M = Converter.MUI
    public typealias USR = Converter.USRUI

    let networking: Networking
    let converter: Converter

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    required public init (networking: Networking, converter: Converter) {
        self.networking = networking
        self.converter = converter
    }
    
    // TEMPORARY
    public func createTestConversation() {
        networking.createTestConversation()
    }
}
    
// MARK: Sending messages
extension ChatCore {
    open func send(message: MS, to conversation: ChatIdentifier, completion: @escaping (Result<M, ChatError>) -> Void) {

        // FIXME: Solve without explicit type casting
        let mess = converter.convert(messageSpecification: message)
        networking.send(message: mess, to: conversation) { [weak self] result in
            switch result {
            case .success(let message):
                if let converted = self?.converter.convert(message: message) {
                    completion(.success(converted))
                }
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
        let listener = networking.listenToConversations() { [weak self] result in
            switch result {
            case .success(let conversations):
                let converted = conversations.compactMap({ self?.converter.convert(conversation: $0) })
                completion(.success(converted))
            case .failure(let error):
                completion(.failure(error))
            }
        }

        return listener
    }

    open func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener {

        // FIXME: Solve without explicit type casting
        let listener = networking.listenToConversation(with: id) { [weak self] result in
                   switch result {
                   case .success(let messages):
                       let converted = messages.compactMap({ self?.converter.convert(message: $0) })
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
