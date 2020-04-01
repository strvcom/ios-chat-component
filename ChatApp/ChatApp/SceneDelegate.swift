//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

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
        // TODO: CJ TEST PURPOSE
        try? Auth.auth().signOut()

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
        chat.setCurrentUser(userId: user.id, name: user.name, imageUrl: user.imageUrl)
        window?.rootViewController = chat.conversationsList()
    }
}
