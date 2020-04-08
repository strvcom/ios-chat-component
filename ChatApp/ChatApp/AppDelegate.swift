//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Chat
import Firebase
import FirebaseUI

// swiftlint:disable implicitly_unwrapped_optional
/// Global chat component for simplicity
var chat: PumpkinPieChat!
var firebaseAuthentication: FirebaseAuthentication!
// swiftlint:enable implicitly_unwrapped_optional

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
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
            chat.runBackgroundTasks { result in
                completionHandler(result)
            }
            return
        }
        completionHandler(.noData)
    }
}

// MARK: Firebase auth UI callback
extension AppDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {

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
