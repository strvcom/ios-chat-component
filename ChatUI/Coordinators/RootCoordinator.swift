//
//  RootCoordinator.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

class RootCoordinator<Core: ChatUICoreServicing>: Coordinating {
    
    private lazy var navigationController: UINavigationController = {
        return UINavigationController(rootViewController: makeConversationsListController())
    }()
    
    private var conversationsListController: ConversationsListViewController?
    
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
    func navigate(to conversation: Conversation) {
        navigationController.pushViewController(
            makeMessagesListController(conversation: conversation),
            animated: true
        )
    }
    
    func emptyStateAction() {
        delegate?.conversationsListEmptyListAction()
    }
}

// MARK: Controllers
private extension RootCoordinator {
    func makeConversationsListController() -> ConversationsListViewController {
        conversationsListController = ConversationsListViewController(
            viewModel: ConversationsListViewModel(core: core)
        )
        
        guard let controller = conversationsListController else {
            fatalError("Couldn't instantiate ConversationsListController")
        }

        controller.coordinator = self
        
        return controller
    }
    
    func makeMessagesListController(conversation: Conversation) -> UIViewController {
        MessagesListViewController(
            viewModel: MessagesListViewModel(
                conversation: conversation,
                core: core
            )
        )
    }
}
