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

    init() {}

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
