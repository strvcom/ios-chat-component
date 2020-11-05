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
    /// Sets current user as typing user
    ///
    /// - Parameters:
    ///   - isTyping: flag if current user is / isn't typing
    ///   - conversation: Conversation id
    func setCurrentUserTyping(isTyping: Bool, in conversation: TypingStatusRepresenting)
}
