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
    associatedtype C: ConversationRepresenting
    // Specific message type
    associatedtype M: MessageRepresenting
    // Message description used for sending a message
    associatedtype MS: MessageSpecifying

    typealias U = C.User

    init(config: Config)
    
    func send(message: MS, to conversation: ChatIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)

    func listenToConversations(completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener

    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener

    func remove(listener: ChatListener)
}
