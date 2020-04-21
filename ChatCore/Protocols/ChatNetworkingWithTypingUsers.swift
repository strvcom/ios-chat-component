//
//  ChatNetworkingWithTyping.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/15/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
/// Defines networking with ability to listen and manage users who are typing
public protocol ChatNetworkingWithTypingUsers {
    // User type
    associatedtype TU: UserRepresenting

    /// Manages user who is typing in conversation
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - conversation: Conversation id
    ///   - isTyping: flag if current user is / isn't typing
    func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: EntityIdentifier)

    /// Creates a listener to typing users. First set of data is received immediately by the completion callback.
    ///
    /// - Parameters:
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToTypingUsers(in conversation: EntityIdentifier, completion: @escaping (Result<[TU], ChatError>) -> Void)
}
