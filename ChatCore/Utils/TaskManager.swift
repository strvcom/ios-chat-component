//
//  Test.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

// MARK: Helper class to automatically manage closures by applying various attributes
final class TaskManager {
    enum RetryType {
        case finite(attempts: Int = 3)
        case infinite
    }

    enum TaskCompletionResult {
        case success
        case failure(ChatError)
    }

    enum TaskAttribute: Hashable {
        case afterInit
        case backgroundTask
        case backgroundThread
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

    typealias TaskCompletionResultHandler = (TaskCompletionResult) -> Void

    // closure storage for calls before init
    private var cachedBeforeInitCalls: [IdentifiableClosure<TaskCompletionResultHandler, Void>: Set<TaskAttribute>] = [:]
    // tasks hooked to background task
    private var backgroundCalls = [IdentifiableClosure<TaskCompletionResultHandler, Void>]()
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    // dedicated thread queue
    private let dispatchQueue = DispatchQueue(label: "com.strv.taskmanager", qos: .background)

    // retry tasks stack
    private var retryCalls: [IdentifiableClosure<TaskCompletionResultHandler, Void>: RetryType] = [:]

    var initialized = false {
        didSet {
            if initialized {
                runCachedTasks()
            }
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
        print("HandleTaskCompletionResult task id \(identifiableClosure.id) with result \(result)")

        // retry in case of network error
        if case .failure(let error) = result, case .networking = error, let retryType = retryCalls[identifiableClosure] {
            // run again whole flow
            print("Retry task id \(identifiableClosure.id), retry type \(retryType)")
            if case .finite(let attempts) = retryType, attempts > 0 {
                run(attributes: attributes, identifiableClosure)
                retryCalls[identifiableClosure] = .finite(attempts: attempts - 1)
            } else if case .infinite = retryType {
                run(attributes: attributes, identifiableClosure)
            } else {
                retryCalls.removeValue(forKey: identifiableClosure)
                // clean up in all cases to release background task
                finishTask(attributes: attributes, identifiableClosure)
            }
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
        print("Finish task id \(identifiableClosure.id) with attributes \(attributes)")
        if attributes.contains(.backgroundTask) {
            finishedInBackgroundTask(id: identifiableClosure.id)
        }
    }
}

// MARK: - After initialization handling
private extension TaskManager {
    func applyAfterInit(_ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, attributes: Set<TaskAttribute>) {
        print("Hook after init task id \(identifiableClosure.id)")
        guard initialized else {
            cachedBeforeInitCalls[identifiableClosure] = attributes
            // to alow chaining
            return
        }
    }

    func runCachedTasks() {
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
            // Expiration handler
            self?.endBackgroundTask()
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
