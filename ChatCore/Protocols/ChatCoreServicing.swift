//
//  ChatCoring.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
public protocol ChatCoreServicing {
    // Networking manager
    associatedtype Networking: ChatNetworkServicing
    associatedtype UIModels: ChatUIModels

    typealias C = UIModels.CUI
    typealias M = UIModels.MUI
    typealias MS = UIModels.MSUI
    typealias U = UIModels.USRUI

    var currentUser: U? { get }

    init(networking: Networking)

    func send(message: MS, to conversation: ChatIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)
    
    func listenToConversations(pageSize: Int, completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener
    
    func loadMoreConversations()

    func listenToMessages(conversation id: ChatIdentifier, pageSize: Int, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener
    
    func loadMoreMessages(conversation id: ChatIdentifier)

    func remove(listener: ChatListener)

    func updateSeenMessage(_ message: M, in conversation: ChatIdentifier)
}

// MARK: Default page size
public extension ChatCoreServicing {
    func listenToConversation(conversation id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener {
        listenToMessages(conversation: id, pageSize: Constants.defaultPageSize, completion: completion)
    }
    
    func listenToConversations(completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener {
        listenToConversations(pageSize: Constants.defaultPageSize, completion: completion)
    }
}
