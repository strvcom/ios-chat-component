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

    func send(message: MS, to conversation: ObjectIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)
    
    func listenToConversations(pageSize: Int, completion: @escaping (Result<DataPayload<[C]>, ChatError>) -> Void) -> ListenerIdentifier
    
    func loadMoreConversations()

    func listenToMessages(conversation id: ObjectIdentifier, pageSize: Int, completion: @escaping (Result<DataPayload<[M]>, ChatError>) -> Void) -> ListenerIdentifier
    
    func loadMoreMessages(conversation id: ObjectIdentifier)

    func remove(listener: ListenerIdentifier)

    func updateSeenMessage(_ message: M, in conversation: ObjectIdentifier)
}

// MARK: Default page size
public extension ChatCoreServicing {
    func listenToMessages(conversation id: ObjectIdentifier, completion: @escaping (Result<DataPayload<[M]>, ChatError>) -> Void) -> ListenerIdentifier {
        listenToMessages(conversation: id, pageSize: Constants.defaultPageSize, completion: completion)
    }
    
    func listenToConversations(completion: @escaping (Result<DataPayload<[C]>, ChatError>) -> Void) -> ListenerIdentifier {
        listenToConversations(pageSize: Constants.defaultPageSize, completion: completion)
    }
}
