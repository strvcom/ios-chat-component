//
//  AppCoordinator.swift
//  ChatApp
//
//  Created by Jan on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat
import Firebase
import FirebaseUI

class AppCoordinator {
    let chat: PumpkinPieChat
    let firebaseAuthentication: FirebaseAuthentication
    
    private var childCoordinators: [SceneCoordinator] = []

    init() {
        guard let configUrl = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            fatalError("Missing firebase configuration file")
        }
        guard let options = FirebaseOptions(contentsOfFile: configUrl) else {
            fatalError("Can't configure Firebase")
        }

        FirebaseApp.configure(options: options)
        let database = Firestore.firestore()
        firebaseAuthentication = FirebaseAuthentication(database: database)
        
        let uiConfig = PumpkinPieChat.UIConfiguration(
            fonts: AppStyleConfig.fonts,
            colors: AppStyleConfig.colors,
            strings: PumpkinPieChat.UIConfiguration.Strings(
                newConversation: "Wants to chat!",
                conversation: "Conversation",
                conversationsListEmptyTitle: "No matches yet",
                conversationsListEmptySubtitle: "Finish quizzes and get more matches",
                conversationsListEmptyActionTitle: "Take a Quiz"
            ),
            images: AppStyleConfig.images
        )
        let networkConfig = PumpkinPieChat.NetworkConfiguration(configUrl: configUrl)
        chat = PumpkinPieChat(networkConfig: networkConfig, uiConfig: uiConfig)
    }
    
    func startScene(with window: UIWindow) -> SceneCoordinator {
        let coordinator = SceneCoordinator(parent: self, window: window)
        
        childCoordinators.append(coordinator)
        
        return coordinator
    }
    
    func disconnect(coordinator: SceneCoordinator) {
        childCoordinators = childCoordinators.filter({ ObjectIdentifier(coordinator) != ObjectIdentifier($0) })
    }
    
    func handleOpen(url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        guard let sourceApplication = options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String else {
            return false
        }
        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
            return true
        }
        // other URL handling goes here.
        return false
    }
}
