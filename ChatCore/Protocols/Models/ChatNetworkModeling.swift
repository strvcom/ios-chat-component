//
//  ChatNetworkModeling.swift
//  ChatCore
//
//  Created by Jan on 28/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// This protocol is used to specify concrete implementations of network models
public protocol ChatNetworkModeling {
    associatedtype NetworkConversation: ConversationRepresenting
    associatedtype NetworkMessage where NetworkMessage == NetworkConversation.Message
    associatedtype NetworkMessageSpecification: MessageSpecifying
    associatedtype NetworkUser where NetworkUser == NetworkConversation.User
}
