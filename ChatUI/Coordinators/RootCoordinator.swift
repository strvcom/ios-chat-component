//
//  RootCoordinator.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

class RootCoordinator<Core: ChatUICoreServicing> {
    private let core: Core
    
    lazy var conversationsViewController: ConversationsListViewController = {
        makeConversationsListController()
    }()

    init(core: Core) {
        self.core = core
    }
}

// MARK: RootCoordinating
extension RootCoordinator: RootCoordinating {
    func messagesViewController(for conversationId: EntityIdentifier) -> MessagesListViewController {
        makeMessagesListController(conversationId: conversationId)
    }
}

// MARK: Controllers
private extension RootCoordinator {
    func makeConversationsListController() -> ConversationsListViewController {
        let controller = ConversationsViewController(
            viewModel: ConversationsListViewModel(core: core)
        )
        
        return controller
    }
    
    func makeMessagesListController(conversationId: EntityIdentifier) -> MessagesListViewController {
        let controller = MessagesViewController(
            viewModel: MessagesListViewModel(
                conversationId: conversationId,
                core: core
            )
        )
        
        return controller
    }
}
