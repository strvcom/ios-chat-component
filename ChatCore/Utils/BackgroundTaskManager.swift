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

        // Wrap closure into identifiable
        let identifiableClosure = IdentifiableClosure(closure)

        // after init is special, need to be initialized before running tasks
        guard (attributes.contains(.afterInit) && initialized) || !attributes.contains(.afterInit) else {
            applyAfterInit(identifiableClosure, attributes: attributes)
            return
        }

        // recurse call in background thread
        guard !attributes.contains(.backgroundThread) else {
            DispatchQueue.global(qos: .background).async { [weak self] in
                var newAttributes = attributes
                newAttributes.remove(.backgroundThread)
                self?.run(closure, attributes: newAttributes)
            }
            return
        }

        print(" Current thread \(Thread.current) isMain \(Thread.current.isMainThread) in function \(#function)")

        applyAttributes(identifiableClosure, attributes: attributes)

        // run closure it self with cleanup callback
        identifiableClosure.closure { [weak self] in
            self?.finishTask(id: identifiableClosure.id, attributes: attributes)
        }
    }
}


// MARK: - Apply similar logic
private extension TaskManager {
    func applyAttributes(_ closure: IdentifiableClosure<EmptyClosure, Void>, attributes: Set<TaskAttribute>) {
        print(" Current thread \(Thread.current) isMain \(Thread.current.isMainThread) in function \(#function)")
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
        print("Hook after init task")
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

        print("Run \(cachedBeforeInitCalls.count) cached tasks before init")
        cachedBeforeInitCalls.forEach { (key, value) in
            run(key.closure, attributes: value)
        }
        cachedBeforeInitCalls.removeAll()
    }
}

// MARK: - Background task handling
private extension TaskManager {

    func applyBackgroundTask(_ closure: IdentifiableClosure<EmptyClosure, Void>) {
        print("Hook closure to background task")
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
        print("Background task registered")
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: UUID().uuidString) { [weak self] in
            // Expiration handler
            self?.endBackgroundTask()
        }
    }

    func endBackgroundTask() {
        if backgroundTask != .invalid {
            print("Background task ended")
            // clean up
            UIApplication.shared.endBackgroundTask(backgroundTask)
            backgroundTask = .invalid
            backgroundCalls.removeAll()
        }
    }
}

// FIXME: TODO: Temp help method to test functionality with long running tasks
// MARK: - After initialization handling
private extension TaskManager {
    func delay(by seconds: TimeInterval, on queue: DispatchQueue = .main, closure: @escaping () -> Void) {
        queue.asyncAfter(
            deadline: .now() + seconds,
            execute: closure
        )
    }
}
