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
        return CustomNavigationController(rootViewController: makeConversationsListController())
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
    func navigate(to conversation: Conversation) {
        navigationController.pushViewController(
            makeMessagesListController(conversation: conversation),
            animated: true
        )
    }
    
    func emptyStateAction() {
        delegate?.conversationsListEmptyListAction()
    }
    
    func conversationDetailMoreButtonAction(conversation: Conversation) {
        delegate?.conversationDetailMoreButtonTapped(conversation: conversation)
    }
}

// MARK: Controllers
private extension RootCoordinator {
    func makeConversationsListController() -> ConversationsListViewController {
        let controller = ConversationsListViewController(
            viewModel: ConversationsListViewModel(core: core)
        )

        controller.coordinator = self
        
        return controller
    }
    
    func makeMessagesListController(conversation: Conversation) -> UIViewController {
        let controller = MessagesListViewController(
            viewModel: MessagesListViewModel(
                conversation: conversation,
                core: core
            )
        )
        
        controller.coordinator = self
        
        return controller
    }
}
