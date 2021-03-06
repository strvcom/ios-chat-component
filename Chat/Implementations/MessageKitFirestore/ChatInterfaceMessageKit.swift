//
//  ChatInterfaceMessageKit.swift
//  Chat
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatUI
import ChatCore

public class ChatInterfaceMessageKit<Models: ChatMessageKitFirestoreModeling>: ChatInterfacing {
    public let identifier: ObjectIdentifier
    public let uiService: ChatUI<ChatMessageKitFirestore<Models>.Core, ChatMessageKitFirestore<Models>.UIModels>
    
    public var conversationsViewController: ConversationsListViewController {
        uiService.conversationsViewController
    }
        
    init(identifier: ObjectIdentifier, core: ChatMessageKitFirestore<Models>.Core, config: UIService.Config) {
        self.identifier = identifier
        self.uiService = ChatMessageKitFirestore.uiService(core: core, uiConfig: config)
    }
    
    public func messagesViewController(for conversationId: EntityIdentifier) -> MessagesListViewController {
        uiService.messagesViewController(for: conversationId)
    }
}
