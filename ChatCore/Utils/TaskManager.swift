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

    enum TaskCompletionResult {
        case success
        case failure(ChatError)
    }

    typealias TaskCompletionResultHandler = (TaskCompletionResult) -> Void

    // closure storage for calls before init
    private var cachedBeforeInitCalls: [IdentifiableClosure<TaskCompletionResultHandler, Void>: Set<TaskAttribute>] = [:]
    // tasks hooked to background task
    private var backgroundCalls = [IdentifiableClosure<TaskCompletionResultHandler, Void>]()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    private let backgroundTaskIdentifier = "com.strv.chatcore.backgroundtask"

    // dedicated thread queue
    private let dispatchQueue = DispatchQueue(label: "com.strv.taskmanager", qos: .background)

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
            // TODO:
            //registerBackgroundTaskScheduler()

            NotificationCenter.default.addObserver(self, selector: #selector(performBackgroundFetch), name: .appPerformBackgroundFetch, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(performBackgroundFetch), name: .appPerformBackgroundFetch, object: nil)
        }
    }

    func run(attributes: Set<TaskAttribute> = [], _ closure: @escaping ((@escaping TaskCompletionResultHandler) -> Void)) {
        // Wrap closure into identifiable struct
        let identifiableClosure = IdentifiableClosure(closure)
        run(attributes: attributes, identifiableClosure)
    }

    private func run(attributes: Set<TaskAttribute> = [], _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {

        print("Run closure with id \(identifiableClosure.id) with attributes \(attributes)")

        // after init is special, need to be initialized before running tasks
        guard (attributes.contains(.afterInit) && initialized) || !attributes.contains(.afterInit) else {
            applyAfterInit(identifiableClosure, attributes: attributes)
            return
        }

        // recursive call in background thread
        guard !attributes.contains(.backgroundThread) else {
            dispatchQueue.async { [weak self] in
                print("Run in background thread task id \(identifiableClosure.id)")
                var newAttributes = attributes
                newAttributes.remove(.backgroundThread)
                self?.run(attributes: newAttributes, identifiableClosure)
            }
            return
        }

        applyAttributes(identifiableClosure, attributes: attributes)

        // run closure it self with cleanup callback
        identifiableClosure.closure { [weak self] _ in
            print("Clean up after task id \(identifiableClosure.id)")
            self?.finishTask(id: identifiableClosure.id, attributes: attributes)
        }
    }
}

// MARK: - Apply similar logic
private extension TaskManager {
    func applyAttributes(_ closure: IdentifiableClosure<TaskCompletionResultHandler, Void>, attributes: Set<TaskAttribute>) {
        if attributes.contains(.backgroundTask) {
            applyBackgroundTask(closure)
        }
    }
}

// MARK: - Clean up management
private extension TaskManager {
    private func finishTask(id: ObjectIdentifier, attributes: Set<TaskAttribute>) {
        if attributes.contains(.backgroundTask) {
            finishedInBackgroundTask(id: id)
        }
    }
}

// MARK: - After initialization handling
private extension TaskManager {

    private func applyAfterInit(_ closure: IdentifiableClosure<TaskCompletionResultHandler, Void>, attributes: Set<TaskAttribute>) {
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
            run(attributes: value, key)
        }
        cachedBeforeInitCalls.removeAll()
    }
}

// MARK: - Background task handling
private extension TaskManager {

    func applyBackgroundTask(_ closure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
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
            guard let self = self else {
                return
            }
            // Expiration handler
            self.endBackgroundTask()

            // Schedule background processing
            if #available(iOS 13, *), !self.backgroundCalls.isEmpty {
                self.scheduleBackgroundProcessing()
            }
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            print("UIApplication background task ended")
            // clean up
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            backgroundCalls.removeAll()
        }
    }
}

// MARK: - Custom notifications
public extension NSNotification.Name {
    static let appPerformBackgroundFetch = NSNotification.Name("appPerformBackgroundFetch")
}

/*
 Handling backgroung calls is quite complex. At first all calls (tasks) which can be longer running are called with backgroundTask attribute. That hooks call to UIApplication register backgroundTask which is automatically continuing work when app goes to background. When task is still not finished manager schedules background processing task to run all stored (unfinished tasks) again until all are finished. For ios version below 13 is observed UIApplication perform method to work similar way.
 */

// MARK: - Scheduled background task handling in ios < 13
private extension TaskManager {
    @objc func performBackgroundFetch(notification: Notification) {
        if let completion = notification.object as? VoidClosure<UIBackgroundFetchResult> {
            runBackgroundCalls {
                completion(.newData)
            }
        }
    }

    func runBackgroundCalls(completionHandler: @escaping EmptyClosure) {
        var tasks = backgroundCalls
        // run all stored tasks until all are done
//        backgroundCalls.forEach { task in
//            task.closure {
//            if let index = tasks.firstIndex(of: task) {
//                tasks.remove(at: index)
//            }
//
//            if tasks.isEmpty {
//                completionHandler()
//            }
//            }}
    }
}

// MARK: - Scheduled background task handling in ios 13+
@available(iOS 13.0, *)
private extension TaskManager {
    func registerBackgroundTaskScheduler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: backgroundTaskIdentifier, using: nil) { task in
            guard let task = task as? BGProcessingTask else {
                return
            }
            self.handleBackgroundProcessing(task: task)
        }
    }

    func scheduleBackgroundProcessing() {

        let request = BGProcessingTaskRequest(identifier: backgroundTaskIdentifier)
        request.requiresNetworkConnectivity = true

        // Fetch no earlier than 15 minutes from now
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }

    func handleBackgroundProcessing(task: BGProcessingTask) {
        runBackgroundCalls {
            task.setTaskCompleted(success: true)
        }

        task.expirationHandler = { [weak self] in
            guard let self = self else {
                return
            }

            if !self.backgroundCalls.isEmpty {
                self.scheduleBackgroundProcessing()
            }
        }
    }
}
