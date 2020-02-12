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
   // Message description used for sending a message
    associatedtype MS: MessageSpecifying

    typealias M = C.Message
    typealias U = C.User

    var currentUser: U? { get } 

    init(config: Config)
    
    func send(message: MS, to conversation: ChatIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)

    func updateSeenMessage(_ message: M, to conversation: ChatIdentifier) 

    func listenToConversations(completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener

    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener

    func remove(listener: ChatListener)
}
