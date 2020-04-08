//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var interface: PumpkinPieChat.Interface?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        self.window = UIWindow(windowScene: windowScene)
        setRootViewController()
        self.window?.makeKeyAndVisible()
    }
}

// MARK: - Create chat and present if a
private extension SceneDelegate {

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

extension SceneDelegate: PumpkinPieChat.UIDelegate {
    func conversationsListEmptyListAction() {
        print("Take a Quiz button tapped!")
    }
}
