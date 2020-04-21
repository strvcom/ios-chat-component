//
//  SceneCoordinator.swift
//  ChatApp
//
//  Created by Jan on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat
import ChatUI

class SceneCoordinator {
    weak var parent: AppCoordinator?
    let dependency: AppDependency
    let window: UIWindow
    
    var interface: PumpkinPieChat.Interface?
    
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
        var imageUrl: URL?
        if let userImageUrl = user.imageUrl {
            imageUrl = URL(string: userImageUrl)
        }
        dependency.chat.setCurrentUser(userId: user.id, name: user.name, imageUrl: imageUrl)
        
        let interface: PumpkinPieChat.Interface
        if #available(iOS 13.0, *) {
            interface = makeSceneInterface()
        } else {
            interface = makeInterface()
        }
        
        interface.delegate = self
        self.interface = interface
        
        return interface.rootViewController
    }
    
    func makeInterface() -> PumpkinPieChat.Interface {
        return dependency.chat.interface()
    }
    
    @available(iOS 13.0, *)
    func makeSceneInterface() -> PumpkinPieChat.Interface {
        guard let scene = window.windowScene else {
            fatalError("Scene delegate doesn't have main window")
        }
        
        return dependency.chat.interface(for: scene)
    }
}

extension SceneCoordinator: PumpkinPieChat.UIDelegate {
    func conversationsListEmptyListAction() {
        print("Take a Quiz button tapped!")
    }
    
    func conversationDetailMoreButtonTapped(conversation: Conversation) {
        print("Conversation detail more button tapped ID \(conversation.id)")
    }
}
