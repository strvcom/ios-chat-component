//
//  ChatNetworkingWithTyping.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/15/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Defines networking with ability to listen and manage users who are typing
public protocol ChatNetworkingWithTypingUsers {
    // User type
    associatedtype User: UserRepresenting

    /// Sets typing user
    ///
    /// - Parameters:
    ///   - userId: Typing user userId
    ///   - conversation: Conversation id
    func setTypingUser(userId: EntityIdentifier, in conversation: EntityIdentifier)

    /// Removes typing user from conversation
    ///
    /// - Parameters:
    ///   - userId: Typing user userId
    ///   - conversation: Conversation id
    func removeTypingUser(userId: EntityIdentifier, in conversation: EntityIdentifier)

    /// Creates a listener to typing users. First set of data is received immediately by the completion callback.
    ///
    /// Returns a ListenerIdentifier instance which is later used to cancel the created listener.
    ///
    /// - Parameters:
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToTypingUsers(in conversation: EntityIdentifier, completion: @escaping (Result<[User], ChatError>) -> Void)
}

/// Default extension to insist on proper user type when extending `ChatNetworkServicing`
extension ChatNetworkServicing where Self: ChatNetworkingWithTypingUsers {
    typealias User = UserManager.User
}
