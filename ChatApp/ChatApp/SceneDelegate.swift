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

    // swiftlint:disable:next force_unwrapping
    private let configUrl = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!
    private var firebaseAuthentication: FirebaseAuthentication?

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
        firebaseAuthentication = FirebaseAuthentication(configUrl: configUrl)
        // TODO:
        try? Auth.auth().signOut()

        if let user = firebaseAuthentication?.user {
            showChat(user: user)
        } else {
            guard let authenticationViewController = firebaseAuthentication?.authenticationViewController(loginCompletion: { [weak self] result in
                switch result {
                case .success(let user):
                    self?.showChat(user: user)
                case .failure(let error):
                    print("Firebase authentication failed \(error)")
                }
            }) else {
                fatalError("Firebase login UI failed")
            }
            self.window?.rootViewController = authenticationViewController
        }
    }

    func showChat(user: FirebaseAuth.User) {
        chat.setCurrentUser(userId: user.uid, name: (user.displayName ?? user.email) ?? "")
        window?.rootViewController = chat.conversationsList()
    }
}
