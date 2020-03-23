//
//  RootCoordinator.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import MessageKit

class RootCoordinator<Core: ChatUICoreServicing>: Coordinating {
    
    private var navigationController: UINavigationController?
    private let core: Core
    
    init(core: Core) {
        self.core = core
    }
    
    func start() -> UIViewController {
        conversationsListController()
    }
}


extension RootCoordinator: RootCoordinating {
    func navigate(to conversation: Conversation, sender: Sender) {
        navigationController?.pushViewController(
            messagesListController(conversation: conversation, sender: sender),
            animated: true
        )
    }
}

private extension RootCoordinator {
    func conversationsListController() -> UIViewController {
        
        let controller = ConversationsListViewController(viewModel: ConversationsListViewModel(core: core))
        controller.coordinator = self
        
        let navigationController = UINavigationController(rootViewController: controller)
        
        self.navigationController = navigationController
        
        return navigationController
    }
    
    func messagesListController(conversation: Conversation, sender: Sender) -> UIViewController {
        MessagesListViewController(conversation: conversation, core: core, sender: sender)
    }
}
