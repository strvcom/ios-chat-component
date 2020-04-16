//
//  SceneCoordinator.swift
//  ChatApp
//
//  Created by Jan on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat

class SceneCoordinator {
    weak var parent: AppCoordinator?
    let window: UIWindow
    
    var interface: PumpkinPieChat.Interface?
    
    init(parent: AppCoordinator, window: UIWindow) {
        self.parent = parent
        self.window = window
    }
    
    func sceneDidDisconnect() {
        parent?.disconnect(coordinator: self)
    }
    
    func setRootViewController() {
        if let user = firebaseAuthentication.user {
            showChat(user: user)
        } else {
            let authenticationViewController = firebaseAuthentication.authenticationViewController(loginCompletion: { [weak self] result in
                switch result {
                case .success(let user):
                    self?.showChat(user: user)
                case .failure(let error):
                    print("Firebase authentication failed \(error)")
                }
            })
            self.window?.rootViewController = authenticationViewController
        }
    }

    func showChat(user: User) {
        var imageUrl: URL?
        if let userImageUrl = user.imageUrl {
            imageUrl = URL(string: userImageUrl)
        }
        chat.setCurrentUser(userId: user.id, name: user.name, imageUrl: imageUrl)
        
        guard let window = self.window, let scene = window.windowScene else {
            fatalError("Scene delegate doesn't have main window")
        }
        
        interface = chat.interface(for: scene)
        interface?.delegate = self
        window.rootViewController = interface?.rootViewController
    }
}

@available(iOS 13.0, *)
extension SceneCoordinator: PumpkinPieChat.UIDelegate {
    func conversationsListEmptyListAction() {
        print("Take a Quiz button tapped!")
    }
}
