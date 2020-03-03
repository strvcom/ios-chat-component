//
//  Test.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import BackgroundTasks

// MARK: Helper class to automatically manage closures by applying various attributes
final class TaskManager {

    enum TaskAttribute {
        case afterInit
        case backgroundTask
        case backgroundThread
    }

    // closure storage for calls before init
    private var cachedBeforeInitCalls: [IdentifiableClosure<EmptyClosure, Void>: Set<TaskAttribute>] = [:]
    // tasks hooked to background task
    private var backgroundCalls = [IdentifiableClosure<EmptyClosure, Void>]()

    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    var initialized = false {
        didSet {
            if initialized {
                runCachedTasks()
            }
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    init() {
        // for ios 13 use backgroundTasks fallback ios to background fetch
        if #available(iOS 13, *) {
            registerBackgroundTaskScheduler()
            // TODO:
            NotificationCenter.default.addObserver(self, selector: #selector(performBackgroundFetch), name: .appPerformBackgroundFetch, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(performBackgroundFetch), name: .appPerformBackgroundFetch, object: nil)
        }
    }

    func run(_ closure: @escaping VoidClosure<EmptyClosure>, attributes: Set<TaskAttribute> = []) {
        // Wrap closure into identifiable struct
        let identifiableClosure = IdentifiableClosure(closure)
        run(identifiableClosure, attributes: attributes)
    }

    private func run(_ identifiableClosure: IdentifiableClosure<EmptyClosure, Void>, attributes: Set<TaskAttribute> = []) {

        print("Run closure with id \(identifiableClosure.id) with attributes \(attributes)")

        // after init is special, need to be initialized before running tasks
        guard (attributes.contains(.afterInit) && initialized) || !attributes.contains(.afterInit) else {
            applyAfterInit(identifiableClosure, attributes: attributes)
            return
        }

        // recursive call in background thread
        guard !attributes.contains(.backgroundThread) else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                print("Run in background thread task id \(identifiableClosure.id)")
                var newAttributes = attributes
                newAttributes.remove(.backgroundThread)
                self?.run(identifiableClosure, attributes: newAttributes)
            }
            return
        }

        applyAttributes(identifiableClosure, attributes: attributes)

        // run closure it self with cleanup callback
        identifiableClosure.closure { [weak self] in
            print("Clean up after task id \(identifiableClosure.id)")
            self?.finishTask(id: identifiableClosure.id, attributes: attributes)
        }
    }
}

// MARK: - Apply similar logic
private extension TaskManager {
    func applyAttributes(_ closure: IdentifiableClosure<EmptyClosure, Void>, attributes: Set<TaskAttribute>) {
        if attributes.contains(.backgroundTask) {
            applyBackgroundTask(closure)
        }
    }
}

// MARK: - Clean up management
private extension TaskManager {
    private func finishTask(id: ObjectIdentifier, attributes: Set<TaskAttribute>) {
        if attributes.contains(.backgroundTask) {
            finishedInBackgroundTask(id: id )
        }
    }
}

// MARK: - After initialization handling
private extension TaskManager {

    private func applyAfterInit(_ closure: IdentifiableClosure<EmptyClosure, Void>, attributes: Set<TaskAttribute>) {
        print("Hook after init task id \(closure.id)")
        guard initialized else {
            cachedBeforeInitCalls[closure] = attributes
            // to alow chaining
            return
        }
    }

    private func runCachedTasks() {
        guard !cachedBeforeInitCalls.isEmpty else {
            return
        }

        cachedBeforeInitCalls.forEach { (key, value) in
            run(key, attributes: value)
        }
        cachedBeforeInitCalls.removeAll()
    }
}

// MARK: - Background task handling
private extension TaskManager {

    func applyBackgroundTask(_ closure: IdentifiableClosure<EmptyClosure, Void>) {
        print("Hook closure id \(closure.id) to background task")
        // Check if task is set already
        if backgroundTask == .invalid {
            registerBackgroundTask()
        }

        backgroundCalls.append(closure)
    }

    func finishedInBackgroundTask(id: ObjectIdentifier) {
        print("Finished closure with \(id) in background task")
        if let index = backgroundCalls.firstIndex(where: { $0.id == id }) {
            backgroundCalls.remove(at: index)
        }

        if backgroundCalls.isEmpty {
            endBackgroundTask()
        }
    }

    func registerBackgroundTask() {
        print("UIApplication background task registered")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString) { [weak self] in
            // Expiration handler
            self?.endBackgroundTask()

            // if any task not finished schedule background fetch
            // TODO:
//            if !self?.backgroundCalls.isEmpty  {
//                registerBackgroundTaskScheduler()
//            }
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            print("UIApplication background task ended")
            // clean up
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
        }
    }
}

// MARK: - Custom notifications
public extension NSNotification.Name {
    static let appPerformBackgroundFetch = NSNotification.Name("appPerformBackgroundFetch")
}

// MARK: - Scheduled background task handling in ios < 13
private extension TaskManager {
    @objc func performBackgroundFetch(notification: Notification) {
        if let completion = notification.object as? VoidClosure<UIBackgroundFetchResult> {

            completion(.newData)
        }
    }
}

// MARK: - Scheduled background task handling in ios 13+
@available(iOS 13.0, *)
private extension TaskManager {
    func registerBackgroundTaskScheduler() {
//        BGTaskScheduler.shared.register(forTaskWithIdentifier:
//        "com.example.apple-samplecode.ColorFeed.refresh",
//        using: nil)
//          {task in
//             self.handleAppRefresh(task: task as! BGAppRefreshTask)
//          }
    }

    func scheduleAppRefresh() {
//        if #available(iOS 13.0, *) {
//            let request = BGAppRefreshTaskRequest(identifier: "com.example.apple-samplecode.ColorFeed.refresh")
//        } else {
//            // Fallback on earlier versions
//        }
//       // Fetch no earlier than 15 minutes from now
//       request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)
//
//       do {
//          try BGTaskScheduler.shared.submit(request)
//       } catch {
//          print("Could not schedule app refresh: \(error)")
//       }
    }

    func handleAppRefresh(task: BGAppRefreshTask) {
      // Schedule a new refresh task
//      scheduleAppRefresh()
//
//      // Create an operation that performs the main part of the background task
//      let operation = RefreshAppContentsOperation()
//        let test = Operation()
//      // Provide an expiration handler for the background task
//      // that cancels the operation
//      task.expirationHandler = {
//         operation.cancel()
//      }
//
//      // Inform the system that the background task is complete
//      // when the operation completes
//      operation.completionBlock = {
//         task.setTaskCompleted(success: !operation.isCancelled)
//      }
//
//      // Start the operation
//      operationQueue.addOperation(operation)
    }
}
