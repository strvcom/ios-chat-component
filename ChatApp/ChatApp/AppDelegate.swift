//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat
import ChatCore
import ChatNetworkingFirestore
import ChatUI

// swiftlint:disable implicitly_unwrapped_optional
var chat: ChatUI<ChatCore<ChatNetworkingFirestore, ChatModelsUI>, ChatConfig>!

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var core: ChatCore<ChatNetworkingFirestore, ChatModelsUI>!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // swiftlint:disable force_unwrapping
        let configUrl = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")!

        // userFirebaseID is an information that backend is providing
        let userFirebaseID = "vvvDpH50aRIWQdxvjtos"

        let config = Chat.Configuration(configUrl: configUrl, userId: userFirebaseID)
        
        let networking = ChatNetworkingFirestore(config: config)
        core = ChatCore<ChatNetworkingFirestore, ChatModelsUI>(networking: networking)
        chat = ChatUI(
            core: core,
            config: UIConfig(
                fonts: AppStyleConfig.fonts,
                colors: AppStyleConfig.colors,
                strings: .init(
                    newConversation: "Wants to chat!",
                    conversation: "Conversation"
                )
            )
        )
        
        setupBackgroundFetch()

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

// MARK: - Background fetch
extension AppDelegate {
    func setupBackgroundFetch() {
        // background fetch setup for older ios version
        guard #available(iOS 13, *) else {
            UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(10 * 60))
            return
        }
    }

    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Needs to pass completion handler to allow finish background fetch
        guard #available(iOS 13, *) else {
            core.runBackgroundTasks { result in
                completionHandler(result)
            }
            return
        }
        completionHandler(.noData)
    }
}
