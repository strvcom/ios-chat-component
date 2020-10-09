//
//  ChatModels.swift
//  Chat
//
//  Created by Jan on 29/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import Chat

/// This class specifies all necessary networking and UI models of Pumpkin Pie chat
class ChatModels: ChatModeling {
    typealias UIConversation = Conversation
    typealias UIMessage = Message
    typealias UIMessageSpecification = MessageContent
    typealias UIUser = User
    typealias NetworkConversation = Conversation
    typealias NetworkMessage = Message
    typealias NetworkMessageSpecification = MessageContent
    typealias NetworkUser = User
}
