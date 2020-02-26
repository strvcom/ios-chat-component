//
//  Test.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

// MARK: Background task management
import UIKit
final class BackgroundTaskManager {
    
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    private var backgroundCalls = [IdentifiableClosure<ChatIdentifier, Void>]()

    func runWithBackgroundTask(closure: @escaping VoidClosure<ChatIdentifier>) {
        print("Hook closure to background task")
        // Check if task is set already
        if backgroundTask == .invalid {
            registerBackgroundTask()
        }

        // Wrap closure into identifiable one and add it to queue
        let identifiableClosure = IdentifiableClosure(closure)
        backgroundCalls.append(identifiableClosure)
        closure(identifiableClosure.id)
    }

    func registerBackgroundTask() {
        print("Background task registered")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString) { [weak self] in
            // Expiration handler
            self?.endBackgroundTask()
        }
    }

    func finishedInBackgroundTask(id: ChatIdentifier) {
        print("Finished closure with \(id) in background task")
        if let index = backgroundCalls.firstIndex(where: { $0.id == id }) {
            backgroundCalls.remove(at: index)
        }

        if backgroundCalls.isEmpty {
            endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        print("Background task ended")
        // clean up
        UIApplication.shared.endBackgroundTask(backgroundTask)
        backgroundTask = .invalid
        backgroundCalls.removeAll()
    }
}
