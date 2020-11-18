//
//  ChatUI.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

let logger = ChatLogger()

public class ChatUI<Core: ChatUICoreServicing, Models: ChatUIModeling>: ChatUIServicing {
    let core: Core
    
    private lazy var coordinator = RootCoordinator(core: core)
    
    // Logger
    public var logLevel: ChatLogLevel {
        get { logger.level }
        set { logger.level = newValue }
    }

    public var conversationsViewController: ConversationsListViewController {
        coordinator.conversationsViewController
    }

    public required init(core: Core, config: UIConfig) {
        self.core = core
        UIConfig.current = config
    }
    
    public func messagesViewController(for conversationId: EntityIdentifier) -> MessagesListViewController {
        coordinator.messagesViewController(for: conversationId)
    }
}
