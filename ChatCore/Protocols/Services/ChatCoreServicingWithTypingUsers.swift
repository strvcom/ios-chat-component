//
//  ChatCoreServicingWithTypingUsers.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/16/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Defines networking with ability to listen and manage users who are typing
public protocol ChatCoreServicingWithTypingUsers {
    // User type
    associatedtype TypingUser: UserRepresenting

    /// Sets current user as typing user
    ///
    /// - Parameters:
    ///   - isTyping: flag if current user is / isn't typing
    ///   - conversation: Conversation id
    func setCurrentUserTyping(isTyping: Bool, in conversation: EntityIdentifier)

    /// Creates a listener to typing users. First set of data is received immediately by the completion callback.
    ///
    /// Returns a ListenerIdentifier instance which is later used to cancel the created listener.
    ///
    /// - Parameters:
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToTypingUsers(in conversation: EntityIdentifier, completion: @escaping (Result<[TypingUser], ChatError>) -> Void) -> Listener
}

/// Default type requirement for user at `ChatCoreServicing`
public extension ChatCoreServicing where Self: ChatCoreServicingWithTypingUsers {
    typealias TypingUser = CoreUser
}
