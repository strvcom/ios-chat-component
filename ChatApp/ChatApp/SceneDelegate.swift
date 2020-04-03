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
    var interface: MessageKitInterface?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }
                
        window = UIWindow(windowScene: windowScene)

        interface = chat.interface(for: scene)
        interface?.delegate = self
        window?.rootViewController = interface?.rootViewController
        window?.makeKeyAndVisible()
    }
}

extension SceneDelegate: MessageKitInterface.Delegate {
    func conversationsListEmptyListAction() {
        print("Take a Quiz button tapped!")
    }
}
