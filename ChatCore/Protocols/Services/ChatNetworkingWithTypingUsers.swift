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
    /// Manages user who is typing in conversation
    ///
    /// - Parameters:
    ///   - userId: User id
    ///   - conversation: Conversation id
    ///   - isTyping: flag if current user is / isn't typing
    func setUserTyping(userId: EntityIdentifier, isTyping: Bool, in conversation: EntityIdentifier)
}
