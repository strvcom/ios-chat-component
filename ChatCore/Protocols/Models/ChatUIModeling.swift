//
//  ChatUIModeling.swift
//  ChatCore
//
//  Created by Mireya Orta on 2/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// This protocol is used to specify concrete implementations of UI models
public protocol ChatUIModeling {
    associatedtype UIConversation: ConversationRepresenting
    associatedtype UIMessage where UIMessage == UIConversation.Message
    associatedtype UIMessageSpecification: MessageSpecifying
    associatedtype UIUser where UIUser == UIConversation.User
}
