//
//  PumpkinPieModels.swift
//  Chat
//
//  Created by Jan on 29/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import Chat

/// This class specifies all necessary networking and UI models of Pumpkin Pie chat
public class PumpkinPieModels: ChatModeling {
    public typealias UIConversation = Conversation
    public typealias UIMessage = Message
    public typealias UIMessageSpecification = MessageSpecification
    public typealias UIUser = User
    public typealias NetworkConversation = Conversation
    public typealias NetworkMessage = Message
    public typealias NetworkMessageSpecification = MessageSpecification
    public typealias NetworkUser = User
}
