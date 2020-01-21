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
    associatedtype Converter: ChatModelConverting

    typealias Networking = Converter.Networking
    typealias C = Converter.CUI
    typealias M = Converter.MUI
    typealias MS = Converter.MSUI

    init(networking: Networking, converter: Converter)
    
    ///
    /// This method is used to do any preparations necessary for the Chat to work
    /// - Parameter completion: called after everything is ready
    ///
    func load(completion: @escaping (Error?) -> Void)

    func send(message: MS, to conversation: ChatIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)

    func listenToConversations(completion: @escaping (Result<[C], ChatError>) -> Void) -> ChatListener

    func listenToConversation(with id: ChatIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void) -> ChatListener

    func remove(listener: ChatListener)
}
