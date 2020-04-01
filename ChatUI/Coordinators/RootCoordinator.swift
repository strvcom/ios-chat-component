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
    private weak var delegate: ChatUIDelegate?
    
    init(core: Core, delegate: ChatUIDelegate?) {
        self.core = core
        self.delegate = delegate
    }
    
    func start() -> UIViewController {
        navigationController
    }
}


extension RootCoordinator: RootCoordinating {
    func navigate(to conversation: Conversation, user: User) {
        navigationController.pushViewController(
            messagesListController(conversation: conversation, user: user),
            animated: true
        )
    }
    
    func emptyStateAction() {
        delegate?.conversationsListEmptyListAction()
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
    
    func messagesListController(conversation: Conversation, user: User) -> UIViewController {
        MessagesListViewController(conversation: conversation, core: core, sender: user)
    }
}
