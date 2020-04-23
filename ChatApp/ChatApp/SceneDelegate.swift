//
//  SceneDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    
    var coordinator: SceneCoordinator?
    
    var appCoordinator: AppCoordinator {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Can't get reference to application delegate")
        }
        
        return appDelegate.coordinator
    }

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else {
            return
        }

        let window = UIWindow(windowScene: windowScene)
        
        self.window = window
        self.coordinator = appCoordinator.startScene(with: window)
        
        self.coordinator?.setRootViewController()
        
        self.window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        coordinator?.sceneDidDisconnect()
    }
}
