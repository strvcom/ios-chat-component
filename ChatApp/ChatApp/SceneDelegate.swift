//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat

/// Global chat component for simplicity
var chat: Chat?

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    // swiftlint:disable:next force_unwrapping
    private let configUrl = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let firebaseAuthentication = FirebaseAuthentication(configUrl: configUrl)

        self.window = UIWindow(windowScene: windowScene)

        if let userId = firebaseAuthentication.userId {
            showChat(userId: userId)
        } else {
            let authenticationViewController = firebaseAuthentication.authenticationViewController { [weak self] result in
                switch result {
                case .success(let user):
                    self?.showChat(userId: user.providerID)
                case .failure(let error):
                    print("Firebase authentication failed \(error)")
                }
            }
            self.window?.rootViewController = authenticationViewController
        }

        self.window?.makeKeyAndVisible()
    }
}

// MARK: - Create chat and present
private extension SceneDelegate {
    func showChat(userId: String) {
        let config = Chat.Configuration(configUrl: configUrl, userId: userId)
        chat = Chat(config: config)
        self.window?.rootViewController = chat?.conversationsList()
    }
}
