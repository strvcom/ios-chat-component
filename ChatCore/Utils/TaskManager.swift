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

    private let maxRetryCount = 3
    private var retryCalls: [IdentifiableClosure<TaskCompletionResultHandler, Void>: Int] = [:]

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

//     func retry(_ attempts: Int, task: EmptyClosure) {
//
//            task { result in
//                print("result from core \(result)")
//            }
//
//            print("CAN CALL THIS")
//
//    //        task({ (obj) in
//    //      success(obj)
//    //    }) { (error) in
//    //      print("Error retry left \(attempts)")
//    //      if attempts > 1 {
//    //        self.retry(attempts - 1, task: task, success: success, failure: failure)
//    //      } else {
//    //          failure(error)
//    //        }
//    //      }
//        }

    private func run(attributes: Set<TaskAttribute> = [], _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>) {

        print("Run closure with id \(identifiableClosure.id) with attributes \(attributes)")

        // after init is special, need to be initialized before running tasks
        guard (attributes.contains(.afterInit) && initialized) || !attributes.contains(.afterInit) else {
            applyAfterInit(identifiableClosure, attributes: attributes)
            return
        }

        // solve background
//        if attributes.contains(.backgroundThread) {
//            dispatchQueue.async { [weak self] in
//                print("Run in background thread task id \(identifiableClosure.id)")
//                self?.runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
//                    print("Clean up after task id \(identifiableClosure.id) with result \(result)")
//                    self?.finishTask(id: identifiableClosure.id, attributes: attributes)
//                })
//            }
//        } else {
//            print("Run in main thread task id \(identifiableClosure.id)")
//            runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
//                print("Clean up after task id \(identifiableClosure.id) with result \(result)")
//                self?.finishTask(id: identifiableClosure.id, attributes: attributes)
//            })
//        }

        let test = { [weak self] in
            if attributes.contains(.backgroundThread) {
                self?.dispatchQueue.async { [weak self] in
                    print("Run in background thread task id \(identifiableClosure.id)")
                    self?.runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
                        print("Clean up after task id \(identifiableClosure.id) with result \(result)")
                        self?.finishTask(id: identifiableClosure.id, attributes: attributes)
                    })
                }
            } else {
                print("Run in main thread task id \(identifiableClosure.id)")
                self?.runClosure(attributes: attributes, identifiableClosure, completionHandler: { [weak self] result in
                    print("Clean up after task id \(identifiableClosure.id) with result \(result)")
                    self?.finishTask(id: identifiableClosure.id, attributes: attributes)
                })
            }
        }

//        retry(3, task: test)
    }

//    func runClosureB(attributes: Set<TaskAttribute> = [], _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, completionHandler: @escaping TaskCompletionResultHandler)


    func runClosure(attributes: Set<TaskAttribute> = [], _ identifiableClosure: IdentifiableClosure<TaskCompletionResultHandler, Void>, completionHandler: @escaping TaskCompletionResultHandler) {
        applyAttributes(identifiableClosure, attributes: attributes)
        identifiableClosure.closure(completionHandler)
    }
}

// MARK: - Apply similar logic
private extension TaskManager {
    func applyAttributes(_ closure: IdentifiableClosure<TaskCompletionResultHandler, Void>, attributes: Set<TaskAttribute>) {
        if attributes.contains(.backgroundTask) {
            applyBackgroundTask(closure)
        }

        if attributes.contains(.retry) {
            retryCalls[closure] = maxRetryCount
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
