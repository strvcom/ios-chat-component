//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Jan on 21/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import Firebase
import FirebaseUI
import Chat

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    // iOS 12 properties
    var window: UIWindow?
    var sceneCoordinator: SceneCoordinator?

    // swiftlint:disable:next implicitly_unwrapped_optional
    var coordinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        let dependency = makeDependencies()
        coordinator = AppCoordinator(dependency: dependency)

        setupBackgroundFetch()
        
        if #available(iOS 13.0, *) {} else {
            setupInitialScene()
        }
        
        return true
    }
}

// MARK: iOS 12 setup
private extension AppDelegate {
    func setupInitialScene() {
        let window = UIWindow(frame: UIScreen.main.bounds)
        
        self.window = window
        self.sceneCoordinator = coordinator.startScene(with: window)
        
        self.sceneCoordinator?.setRootViewController()
        
        self.window?.makeKeyAndVisible()
    }
}
    
// MARK: UISceneSession Lifecycle
@available(iOS 13.0, *)
extension AppDelegate {
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
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
            let chat = coordinator.dependency.chat
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
//        if FUIAuth.defaultAuthUI()?.handleOpen(url, sourceApplication: sourceApplication) ?? false {
//            return true
//        }
        // other URL handling goes here.
        return false
    }
}

// MARK: Dependencies
private extension AppDelegate {
    func makeDependencies() -> AppDependency {
        guard let configUrl = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
            fatalError("Missing firebase configuration file")
        }
        guard let options = FirebaseOptions(contentsOfFile: configUrl) else {
            fatalError("Can't configure Firebase")
        }

        FirebaseApp.configure(options: options)
        let database = Firestore.firestore()
        let firebaseAuthentication = FirebaseAuthentication(database: database)
        
        let uiConfig = PumpkinPieChat.UIConfiguration(
            fonts: AppStyleConfig.fonts,
            colors: AppStyleConfig.colors,
            strings: PumpkinPieChat.UIConfiguration.Strings(
                newConversation: "Wants to chat!",
                conversation: "Conversation",
                conversationsListEmptyTitle: "No matches yet",
                conversationsListEmptySubtitle: "Finish quizzes and get more matches",
                conversationsListEmptyActionTitle: "Take a Quiz",
                conversationsListNavigationTitle: "Conversations",
                messageInputPlaceholder: "Message"
            ),
            images: AppStyleConfig.images
        )
        let networkConfig = PumpkinPieChat.NetworkConfiguration(configUrl: configUrl)
        let chat = PumpkinPieChat(networkConfig: networkConfig, uiConfig: uiConfig)
        
        return AppDependency(chat: chat, firebaseAuthentication: firebaseAuthentication)
    }
}
