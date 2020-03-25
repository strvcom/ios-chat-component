//
//  ConversationsListState.swift
//  ChatUI
//
//  Created by Daniel Pecher on 25/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public struct ConversationsListState {
    let items: [Conversation]
    let currentUser: User
    let reachedEnd: Bool
}
