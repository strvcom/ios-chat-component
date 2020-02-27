//
//  ChatNetworking.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
public protocol ChatNetworkServicing {
    associatedtype Config
    
    // Specific conversation type
    associatedtype C: ConversationRepresenting
    // Message description used for sending a message
    associatedtype MS: MessageSpecifying

    typealias M = C.Message
    typealias U = C.User

    var currentUser: U? { get }
    
    var delegate: ChatNetworkServicingDelegate? { get set }

    init(config: Config)
    
    func send(message: MS, to conversation: ObjectIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)

    func updateSeenMessage(_ message: M, in conversation: C)

    func listenToConversations(pageSize: Int, listener: ListenerIdentifier, completion: @escaping (Result<[C], ChatError>) -> Void)
    
    func loadMoreConversations()

    func listenToMessages(conversation id: ObjectIdentifier, pageSize: Int, listener: ListenerIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void)
    
    func loadMoreMessages(conversation id: ObjectIdentifier)

    func remove(listener: ListenerIdentifier)
}
