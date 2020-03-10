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
        case retry
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

    // dedicated thread queue
    private let dispatchQueue = DispatchQueue(label: "com.strv.taskmanager", qos: .background)

    // retry tasks stack
    private let maxRetryCount = 3
    private var retryCalls: [IdentifiableClosure<TaskCompletionResultHandler, Void>: Int] = [:]

    var initialized = false {
        didSet {
            if initialized {
                runCachedTasks()
            }
        }
    }

    init() {
        // for ios 13 use backgroundTasks fallback ios to background fetch
        if #available(iOS 13, *) {
            registerBackgroundTaskScheduler()
        }
    }

    func run(attributes: Set<TaskAttribute> = [], _ closure: @escaping ((@escaping TaskCompletionResultHandler) -> Void)) {
        // Wrap closure into identifiable struct
        let identifiableClosure = IdentifiableClosure(closure)
        run(attributes: attributes, identifiableClosure)
    }
}

// MARK: - Run task implementation
private extension TaskManager {
    func run(attributes: Set<TaskAttribute> = [], _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        print("Run closure with id \(identifiableClosure.id) with attributes \(attributes)")

        // after init is special, need to be initialized before running tasks
        guard (attributes.contains(.afterInit) && initialized) || !attributes.contains(.afterInit) else {
            applyAfterInit(identifiableClosure, attributes: attributes)
            return
        }

        // solve background
        if attributes.contains(.backgroundThread) {
            dispatchQueue.async { [weak self] in
                print("Run in background thread task id \(identifiableClosure.id)")
                self?.runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
                    self?.handleTaskCompletionResult(attributes: attributes, result: result, identifiableClosure)
                })
            }
        } else {
            print("Run in main thread task id \(identifiableClosure.id)")
            runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
                self?.handleTaskCompletionResult(attributes: attributes, result: result, identifiableClosure)
            })
        }
    }

    func runClosure(attributes: Set<TaskAttribute>, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, completionHandler: @escaping TaskCompletionResultHandler) {
        applyAttributes(attributes: attributes, identifiableClosure)
        identifiableClosure.closure(completionHandler)
    }

    func handleTaskCompletionResult(attributes: Set<TaskAttribute>, result: TaskCompletionResult, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        print("Clean up after task id \(identifiableClosure.id) with result \(result)")

        // retry in case of network error
        if case .failure(let error) = result, case .networking = error, attributes.contains(.retry), let retryCount = retryCalls[identifiableClosure], retryCount > 0 {
            // run again whole flow
            print("Retry task id \(identifiableClosure.id), retry count \(retryCount)")
            run(attributes: attributes, identifiableClosure)
            retryCalls[identifiableClosure] = retryCount - 1
        } else {
            retryCalls.removeValue(forKey: identifiableClosure)
            // clean up in all cases to release background task
            finishTask(attributes: attributes, identifiableClosure)
        }
    }
}

// MARK: - Apply similar logic
private extension TaskManager {
    func applyAttributes(attributes: Set<TaskAttribute>, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        if attributes.contains(.backgroundTask) {
            applyBackgroundTask(identifiableClosure)
        }

        if attributes.contains(.retry) && retryCalls[identifiableClosure] == nil {
            retryCalls[identifiableClosure] = maxRetryCount
        }
    }
}

// MARK: - Clean up management
private extension TaskManager {
    private func finishTask(attributes: Set<TaskAttribute>, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        if attributes.contains(.backgroundTask) {
            finishedInBackgroundTask(id: identifiableClosure.id)
        }
    }
}

// MARK: - After initialization handling
private extension TaskManager {

    private func applyAfterInit(_ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, attributes: Set<TaskAttribute>) {
        print("Hook after init task id \(identifiableClosure.id)")
        guard initialized else {
            cachedBeforeInitCalls[identifiableClosure] = attributes
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

    func applyBackgroundTask(_ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        print("Hook closure id \(identifiableClosure.id) to background task")
        // Check if task is set already
        if backgroundTask == .invalid {
            registerBackgroundTask()
        }

        // check if backgroundCalls doesnt contain task already bc of retry logic
        if !backgroundCalls.contains(identifiableClosure) {
            backgroundCalls.append(identifiableClosure)
        }
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

            // Schedule background processing
            if #available(iOS 13, *), !self.backgroundCalls.isEmpty {
                self.scheduleBackgroundProcessing()
            }

            // Expiration handler
            self.endBackgroundTask()
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

/*
 Handling backgroung calls is quite complex. At first all calls (tasks) which can be longer running are called with backgroundTask attribute. That hooks call to UIApplication register backgroundTask which is automatically continuing work when app goes to background. When task is still not finished manager schedules background processing task to run all stored (unfinished tasks) again until all are finished. For ios version below 13 is observed UIApplication perform method to work similar way.
 */

// MARK: - Run stored unfinished background tasks
extension TaskManager {
    func runBackgroundCalls(completionHandler: @escaping EmptyClosure) {
        let tasks = backgroundCalls
        // run all stored tasks until all are done
        tasks.forEach { task in
            task.closure { [weak self] result in
                guard let self = self else {
                    return
                }
                if case .success = result {
                    if let index = self.backgroundCalls.firstIndex(of: task) {
                        self.backgroundCalls.remove(at: index)
                    }

                    if self.backgroundCalls.isEmpty {
                        completionHandler()
                    }
                }
            }}
    }
}

// MARK: - Scheduled background task handling in ios 13+
@available(iOS 13.0, *)
private extension TaskManager {
    func registerBackgroundTaskScheduler() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: Constants.backgroundTaskIdentifier, using: nil) { task in
            guard let task = task as? BGProcessingTask else {
                return
            }
            self.handleBackgroundProcessing(task: task)
        }
    }

    func scheduleBackgroundProcessing() {

        let request = BGProcessingTaskRequest(identifier: Constants.backgroundTaskIdentifier)
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
