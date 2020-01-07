//
//  ChatNetworking.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatNetworkServicing {
    associatedtype Config
    // Specific conversation type
    associatedtype Conversation: ConversationRepresenting
    // Specific message type
    associatedtype Message: MessageRepresenting
    // Message description used for sending a message
    associatedtype MessageSpecification: MessageSpecifying

    init(config: Config)
    
    func send(message: MessageSpecification, to conversation: ChatIdentifier, completion: @escaping (Result<Message, ChatError>) -> Void)
    
    func listenToConversations(completion: @escaping (Result<[Conversation], ChatError>) -> Void) -> ChatListener
    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[Message], ChatError>) -> Void) -> ChatListener

    func remove(listener: ChatListener)
}
