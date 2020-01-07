//
//  ChatCoring.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatCoreServicing {
    // Networking manager
    associatedtype Networking: ChatNetworkServicing
    
    typealias Conversation = Networking.Conversation
    typealias Message = Networking.Message
    typealias MessageSpecification = Networking.MessageSpecification

    init(networking: Networking)
    
    func send(message: MessageSpecification, to conversation: ChatIdentifier, completion: @escaping (Result<Message, ChatError>) -> Void)
    
    func listenToConversations(completion: @escaping (Result<[Conversation], ChatError>) -> Void) -> ChatListener
    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[Message], ChatError>) -> Void) -> ChatListener
    
    func remove(listener: ChatListener)
}
