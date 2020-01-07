//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

open class ChatCore<Networking: ChatNetworkServicing>: ChatCoreServicing {
    
    let networking: Networking
    
    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic
    
    required public init (networking: Networking) {
        self.networking = networking
    }
}
    
// MARK: Sending messages
extension ChatCore {
    open func send(message: Networking.MessageSpecification, to conversation: ChatIdentifier, completion: @escaping (Result<Networking.Message, ChatError>) -> Void) {

        // FIXME: Solve without explicit type casting
        networking.send(message: message, to: conversation, completion: completion)
    }
}

// MARK: Seen flag
extension ChatCore {
    open func markAsSeen(message: Networking.Message) {
        // TODO: Implement
    }
}

// MARK: Listening to updates
extension ChatCore {
    open func listenToConversations(completion: @escaping (Result<[Networking.Conversation], ChatError>) -> Void) -> ChatListener {
        
        // FIXME: Solve without explicit type casting
        let listener = networking.listenToConversations(completion: completion)
        
        return listener
    }
    
    open func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[Networking.Message], ChatError>) -> Void) -> ChatListener {
        
        // FIXME: Solve without explicit type casting
        let listener = networking.listenToConversation(with: id, completion: completion)
        
        return listener
    }
    
    open func remove(listener: ChatListener) {
        networking.remove(listener: listener)
    }
}
