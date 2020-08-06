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
    
    lazy var conversationsViewController: ChatConversationsListController = {
        makeConversationsListController()
    }()

    init(core: Core) {
        self.core = core
    }
}

// MARK: RootCoordinating
extension RootCoordinator: RootCoordinating {
    func messagesViewController(for conversationId: EntityIdentifier) -> ChatMessagesListController {
        makeMessagesListController(conversationId: conversationId)
    }
}

// MARK: Controllers
private extension RootCoordinator {
    func makeConversationsListController() -> ConversationsListViewController<ConversationsListViewModel<Core>> {
        let controller = ConversationsListViewController(
            viewModel: ConversationsListViewModel(core: core)
        )
        
        return controller
    }
    
    func makeMessagesListController(conversationId: EntityIdentifier) -> ChatMessagesListController {
        let controller = MessagesListViewController(
            viewModel: MessagesListViewModel(
                conversationId: conversationId,
                core: core
            )
        )
        
        return controller
    }
}
