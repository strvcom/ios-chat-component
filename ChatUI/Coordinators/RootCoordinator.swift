//
//  RootCoordinator.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class RootCoordinator<Core: ChatUICoreServicing>: Coordinating {
    
    private lazy var navigationController: UINavigationController = {
        return UINavigationController(rootViewController: conversationsListController())
    }()
    
    private let core: Core
    
    init(core: Core) {
        self.core = core
    }
    
    func start() -> UIViewController {
        navigationController
    }
}


extension RootCoordinator: RootCoordinating {
    func navigate(to conversation: Conversation) {
        navigationController.pushViewController(
            messagesListController(conversation: conversation),
            animated: true
        )
    }
}

private extension RootCoordinator {
    func conversationsListController() -> ConversationsListViewController {
        let controller = ConversationsListViewController(
            viewModel: ConversationsListViewModel(core: core)
        )
        
        controller.coordinator = self
        
        return controller
    }
    
    func messagesListController(conversation: Conversation) -> UIViewController {
        MessagesListViewController(conversation: conversation, core: core)
    }
}
