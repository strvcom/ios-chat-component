//
//  AppDelegate.swift
//  ChatApp
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    // swiftlint:disable:next implicitly_unwrapped_optional
    var coordinator: AppCoordinator!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        coordinator = AppCoordinator()
        
        setupBackgroundFetch()
        return true
    }
}
    
// MARK: UISceneSession Lifecycle
@available(iOS 13.0, *)
extension AppDelegate {
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
            coordinator.chat.runBackgroundTasks { result in
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
        coordinator.handleOpen(url: url, options: options)
    }
}
