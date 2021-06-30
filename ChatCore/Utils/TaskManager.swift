//
//  TaskManager.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import BackgroundTasks

// MARK: Helper class to automatically manage closures by applying various attributes
final class TaskManager {
    /**
     Because dictionary isn't thread-safe and the accessing (reading AND writing) the tasks storage can happen simultaneously within the core queue,
     we have to prevent possible crashes by using dedicated queue to protect the storage and make sure only one thread access it at the time.
     */
    class TaskCache {
        // swiftlint:disable:next nesting
        typealias Closure = IdentifiableClosure<TaskCompletionResultHandler, Void>
        
        private lazy var storage: [Closure: Set<TaskAttribute>] = [:]
        private let queue = DispatchQueue(label: "com.strv.chatcore.taskcache.queue")
        
        subscript(key: Closure) -> Set<TaskAttribute> {
            get {
                queue.sync {
                    storage[key] ?? []
                }
            }
            set {
                queue.sync {
                    storage[key] = newValue
                }
            }
        }
        
        var isEmpty: Bool {
            queue.sync {
                storage.isEmpty
            }
        }
        
        var allTasks: [Closure: Set<TaskAttribute>] {
            queue.sync {
                storage
            }
        }
        
        func removeAll() {
            queue.sync {
                storage.removeAll()
            }
        }
    }
    
    enum RetryType {
        case finite(attempts: Int = 3)
        case infinite
    }

    enum TaskCompletionResult {
        case success
        case failure(ChatError)
    }

    enum TaskCompletionState {
        case finished
        case retrying
    }

    enum TaskAttribute: Hashable {
        case afterInit
        case backgroundTask
        case backgroundThread(DispatchQueue?)
        case retry(RetryType)

        static func == (lhs: TaskManager.TaskAttribute, rhs: TaskManager.TaskAttribute) -> Bool {
            lhs.hashValue == rhs.hashValue
        }

        func hash(into hasher: inout Hasher) {
            switch self {
            case .retry(let retryType):
                switch retryType {
                case .finite(let attempts):
                    hasher.combine("finite \(attempts)")
                default:
                    hasher.combine("\(self)")
                }
            default:
                hasher.combine("\(self)")
            }
        }
    }

    // Validate state of task after result on internal call
    typealias TaskCompletionResultHandler = (TaskCompletionResult) -> TaskCompletionState

    // Closure storage for calls before initialization
    private let taskCache = TaskCache()
    // tasks hooked to background task
    private var backgroundCalls = [IdentifiableClosure<TaskCompletionResultHandler, Void>]()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // dedicated thread queue
    private let dispatchQueue = DispatchQueue(label: "com.strv.taskmanager", qos: .utility)

    // retry tasks stack
    private var retryCalls: [IdentifiableClosure<TaskCompletionResultHandler, Void>: RetryType] = [:]

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
        logger.log("Run closure with id \(identifiableClosure.id) with attributes \(attributes)", level: .debug)

        // after init is special, need to be initialized before running tasks
        guard (attributes.contains(.afterInit) && initialized) || !attributes.contains(.afterInit) else {
            applyAfterInit(identifiableClosure, attributes: attributes)
            return
        }

        // solve threading
        if case .backgroundThread(let queue) = attributes.first(where: { attribute -> Bool in
            if case .backgroundThread = attribute {
                return true
            }
            return false
        }) {

            let dispatchQueue = queue ?? self.dispatchQueue
            dispatchQueue.async { [weak self] in
                logger.log("Run in background thread task id \(identifiableClosure.id)", level: .debug)
                self?.runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
                    guard let self = self else {
                        return .finished
                    }
                    return self.handleTaskCompletionResult(attributes: attributes, result: result, identifiableClosure)
                })
            }

        } else {
            logger.log("Run in main thread task id \(identifiableClosure.id)", level: .debug)
            runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
                guard let self = self else {
                    return .finished
                }
                return self.handleTaskCompletionResult(attributes: attributes, result: result, identifiableClosure)
            })
        }
    }

    func runClosure(attributes: Set<TaskAttribute>, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, completionHandler: @escaping TaskCompletionResultHandler) {
        applyAttributes(attributes: attributes, identifiableClosure)
        identifiableClosure.closure(completionHandler)
    }

    func handleTaskCompletionResult(attributes: Set<TaskAttribute>, result: TaskCompletionResult, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) -> TaskCompletionState {
        logger.log("HandleTaskCompletionResult task id \(identifiableClosure.id) with result \(result)", level: .debug)

        // retry in case of network error
        if case .failure(let error) = result, case .networking = error, let retryType = retryCalls[identifiableClosure] {
            // run again whole flow
            logger.log("Retry task id \(identifiableClosure.id), retry type \(retryType)", level: .debug)
            if case .finite(let attempts) = retryType, attempts > 0 {
                run(attributes: attributes, identifiableClosure)
                retryCalls[identifiableClosure] = .finite(attempts: attempts - 1)
                return .retrying
            } else if case .infinite = retryType {
                run(attributes: attributes, identifiableClosure)
                return .retrying
            } else {
                retryCalls.removeValue(forKey: identifiableClosure)
                // clean up in all cases to release background task
                finishTask(attributes: attributes, identifiableClosure)
                return .finished
            }
        } else {
            retryCalls.removeValue(forKey: identifiableClosure)
            // clean up in all cases to release background task
            finishTask(attributes: attributes, identifiableClosure)
            return .finished
        }
    }
}

// MARK: - Apply similar logic
private extension TaskManager {
    func applyAttributes(attributes: Set<TaskAttribute>, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        if attributes.contains(.backgroundTask) {
            applyBackgroundTask(identifiableClosure)
        }

        if case .retry(let retryType) = attributes.first(where: { attribute -> Bool in
            if case .retry = attribute {
                return true
            }
            return false
        }), retryCalls[identifiableClosure] == nil {
            retryCalls[identifiableClosure] = retryType
        }
    }
}

// MARK: - Clean up management
private extension TaskManager {
    func finishTask(attributes: Set<TaskAttribute>, _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        logger.log("Finish task id \(identifiableClosure.id) with attributes \(attributes)", level: .debug)
        if attributes.contains(.backgroundTask) {
            finishedInBackgroundTask(id: identifiableClosure.id)
        }
    }
}

// MARK: - After initialization handling
private extension TaskManager {
    func applyAfterInit(_ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, attributes: Set<TaskAttribute>) {
        logger.log("Hook after init task id \(identifiableClosure.id)", level: .debug)
        guard initialized else {
            taskCache[identifiableClosure] = attributes
            // to alow chaining
            return
        }
    }

    func runCachedTasks() {
        guard !taskCache.isEmpty else {
            return
        }

        taskCache.allTasks.forEach { (key, value) in
            run(attributes: value, key)
        }
        
        taskCache.removeAll()
    }
}

// MARK: - Background task handling
private extension TaskManager {

    func applyBackgroundTask(_ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {
        logger.log("Hook closure id \(identifiableClosure.id) to background task", level: .debug)
        // Check if task is set already
        if backgroundTask == .invalid {
            registerBackgroundTask()
        }

        // check if backgroundCalls doesnt contain task already bc of retry logic
        if !backgroundCalls.contains(identifiableClosure) {
            backgroundCalls.append(identifiableClosure)
        }
    }

    func finishedInBackgroundTask(id: EntityIdentifier) {
        logger.log("Finished closure with \(id) in background task", level: .debug)
        if let index = backgroundCalls.firstIndex(where: { $0.id == id }) {
            backgroundCalls.remove(at: index)
        }

        if backgroundCalls.isEmpty {
            endBackgroundTask()
        }
    }

    func registerBackgroundTask() {
        logger.log("UIApplication background task registered", level: .debug)
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
            logger.log("UIApplication background task ended", level: .debug)
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
    func runBackgroundCalls(completion: @escaping VoidClosure<UIBackgroundFetchResult>) {
        guard !backgroundCalls.isEmpty else {
            completion(.noData)
            return
        }

        let tasks = backgroundCalls
        // run all stored tasks until all are done
        tasks.forEach { task in
            task.closure { [weak self] result in
                guard let self = self else {
                    return .finished
                }
                if case .success = result {
                    if let index = self.backgroundCalls.firstIndex(of: task) {
                        self.backgroundCalls.remove(at: index)
                    }

                    if self.backgroundCalls.isEmpty {
                        completion(.newData)
                    }
                }
                return .finished
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
            logger.log("Could not schedule app refresh: \(error)", level: .debug)
        }
    }

    func handleBackgroundProcessing(task: BGProcessingTask) {
        runBackgroundCalls { _ in
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
