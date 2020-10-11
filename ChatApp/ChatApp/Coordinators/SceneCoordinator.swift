//
//  SceneCoordinator.swift
//  ChatApp
//
//  Created by Jan on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatUI

final class SceneCoordinator {
    weak var parent: AppCoordinator?
    
    let dependency: AppDependency
    let window: UIWindow
    
    private(set) var interface: ChatService.Interface?
    
    init(parent: AppCoordinator, dependency: AppDependency, window: UIWindow) {
        self.parent = parent
        self.window = window
        self.dependency = dependency
    }
    
    func sceneDidDisconnect() {
        parent?.disconnect(coordinator: self)
    }
    
    func setRootViewController() {
        let rootViewController: UIViewController
        
        if let user = dependency.firebaseAuthentication.user {
            rootViewController = makeChat(user: user)
        } else {
            rootViewController = makeAuthentication()
        }
        
        self.window.rootViewController = rootViewController
    }
}

// MARK: Private methods
private extension SceneCoordinator {
    func makeAuthentication() -> UIViewController {
        let authenticationViewController = dependency.firebaseAuthentication.authenticationViewController(loginCompletion: { [weak self] result in
            switch result {
            case .success:
                self?.setRootViewController()
            case .failure(let error):
                print("Firebase authentication failed \(error)")
            }
        })
        
        return authenticationViewController
    }
    
    func makeChat(user: User) -> UIViewController {
        dependency.chat.setCurrentUser(user: user)
        
        let interface: ChatService.Interface
        if #available(iOS 13.0, *) {
            interface = makeSceneInterface()
        } else {
            interface = makeInterface()
        }
        
        self.interface = interface
        
        var conversationsController = interface.conversationsViewController
        conversationsController.actionsDelegate = self
        return CustomNavigationController(rootViewController: conversationsController)
    }
    
    func makeInterface() -> ChatService.Interface {
        return dependency.chat.interface()
    }
    
    @available(iOS 13.0, *)
    func makeSceneInterface() -> ChatService.Interface {
        guard let scene = window.windowScene else {
            fatalError("Scene delegate doesn't have main window")
        }
        
        return dependency.chat.interface(for: scene)
    }
}

// MARK: Conversations action delegate
extension SceneCoordinator: ConversationsListActionsDelegate {
    func didSelectConversation(conversationId: EntityIdentifier, in controller: UIViewController) {
        guard let interface = interface else {
            return
        }
        guard let navigation = window.rootViewController as? UINavigationController else {
            return
        }
        
        var messagesController = interface.messagesViewController(for: conversationId)
        messagesController.actionsDelegate = self
        navigation.pushViewController(messagesController, animated: true)
    }
    
    func didTapOnEmptyListAction(in controller: UIViewController) {
        print("Take a Quiz button tapped!")
    }
}

// MARK: Messages action delegate
extension SceneCoordinator: MessagesListActionsDelegate {
    func didTapOnMoreButton(for conversationId: EntityIdentifier, in controller: UIViewController) {
        print("Conversation detail more button tapped")
    }
}
