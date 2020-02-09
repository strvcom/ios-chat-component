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
    associatedtype UIModels: ChatUIModels

    typealias C = UIModels.CUI
    typealias M = UIModels.MUI
    typealias MS = UIModels.MSUI
    typealias U = UIModels.USRUI

    var currentUser: U? { get }

    init(networking: Networking)

    func send(message: MS, to conversation: ChatIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)

    func listenToConversations(completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener

    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener
    
    func loadMessages(conversation: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void, updatesListener: ((Result<M, ChatError>) -> Void)?)
    
    func loadMoreMessages(conversation: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void)
    
    func loadConversations(completion: @escaping (Result<[C], ChatError>) -> Void, updatesListener: ((Result<C, ChatError>) -> Void)?)
    
    func loadMoreConversations(completion: @escaping (Result<[C], ChatError>) -> Void)

    func remove(listener: ChatListener)
}
