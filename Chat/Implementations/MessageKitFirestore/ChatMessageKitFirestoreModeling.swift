//
//  ChatMessageKitFirestoreModeling.swift
//  Chat
//
//  Created by Jan on 10/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import ChatNetworkingFirestore
import ChatUI

public protocol ChatMessageKitFirestoreModeling: ChatUIModeling, ChatFirestoreModeling where
    UIMessageSpecification: Cachable,
    UIMessage.MessageSpecification == UIMessageSpecification,
    NetworkConversation: ChatUIConvertible,
    NetworkMessage: ChatUIConvertible,
    NetworkMessageSpecification: ChatUIConvertible,
    NetworkConversation.UIModel == UIConversation,
    NetworkMessage.UIModel == UIMessage,
    NetworkMessageSpecification.UIModel == UIMessageSpecification,
    UIMessage: ContentfulMessageRepresenting,
    UIMessageSpecification: ChatMessageContent,
    UIConversation == NetworkConversation {
}
