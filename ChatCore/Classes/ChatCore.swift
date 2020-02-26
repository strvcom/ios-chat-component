//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

open class ChatCore<Networking: ChatNetworkServicing, Models: ChatUIModels>: ChatCoreServicing
           where Networking.C: ChatUIConvertible, Networking.M: ChatUIConvertible, Networking.MS: ChatUIConvertible,
            Networking.U: ChatUIConvertible, Networking.C.User.ChatUIModel == Models.USRUI,
            Networking.C.ChatUIModel == Models.CUI, Networking.C.Message.ChatUIModel == Models.MUI,
            Networking.MS.ChatUIModel == Models.MSUI {

    public typealias Networking = Networking
    public typealias UIModels = Models
    
    public typealias ConversationUI = Models.CUI
    public typealias MessageSpecifyingUI = Models.MSUI
    public typealias MessageUI = Models.MUI
    public typealias UserUI = Models.USRUI

    private var dataManagers = [ChatListener: DataManager]()

    private var networking: Networking
    private var cachedCalls = [() -> Void]()
    private var backgroundCalls = [IdentifiableClosure<ChatIdentifier, Void>]()
    private var initialized = false
    private var backgroundTask: UIBackgroundTaskIdentifier = .invalid

    public var currentUser: UserUI? {
        guard let currentUser = networking.currentUser else {
            return nil
        }
        return currentUser.uiModel
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    public required init (networking: Networking) {
        self.networking = networking
        self.networking.delegate = self
    }
}

// MARK: Sending messages
extension ChatCore {
    open func send(message: MessageSpecifyingUI, to conversation: ChatIdentifier,
                   completion: @escaping (Result<MessageUI, ChatError>) -> Void) {

        runAfterInit { [weak self] in
            self?.runWithBackgroundTask { [weak self] id in
                let mess = Networking.MS(uiModel: message)
                self?.networking.send(message: mess, to: conversation) { result in
                    // clean up closure from background task
                    self?.finishedInBackgroundTask(id: id)
                    switch result {
                    case .success(let message):
                        completion(.success(message.uiModel))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

// MARK: Seen flag
extension ChatCore {
    open func updateSeenMessage(_ message: MessageUI, in conversation: ChatIdentifier) {
        let seenMessage = Networking.M(uiModel: message)
        networking.updateSeenMessage(seenMessage, in: conversation)
    }
}

// MARK: Listening to updates
extension ChatCore {
    open func listenToConversations(pageSize: Int, completion: @escaping (Result<DataPayload<[ConversationUI]>, ChatError>) -> Void) -> ChatListener {
        let listener = ChatListener.generateIdentifier()
        
        dataManagers[listener] = DataManager(pageSize: pageSize)

        runAfterInit { [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToConversations(pageSize: pageSize, listener: listener) { result in
                switch result {
                case .success(let conversations):
                    
                    self.dataManagers[listener]?.update(data: conversations)
                    
                    let converted = conversations.compactMap({ $0.uiModel })
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        return listener
    }
    
    open func loadMoreConversations() {
        networking.loadMoreConversations()
    }

    open func listenToMessages(
        conversation id: ChatIdentifier,
        pageSize: Int,
        completion: @escaping (Result<DataPayload<[MessageUI]>, ChatError>) -> Void
    ) -> ChatListener {
        let listener = ChatListener.generateIdentifier()

        dataManagers[listener] = DataManager(pageSize: pageSize)
        
        runAfterInit { [weak self] in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToMessages(conversation: id, pageSize: pageSize, listener: listener) { result in
                switch result {
                case .success(let messages):
                    
                    self.dataManagers[listener]?.update(data: messages)
                    
                    let converted = messages.compactMap({ $0.uiModel })
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }

        return listener
    }
    
    open func loadMoreMessages(conversation id: ChatIdentifier) {
        networking.loadMoreMessages(conversation: id)
    }
    
    open func remove(listener: ChatListener) {
        networking.remove(listener: listener)
        dataManagers[listener] = nil
    }
}

// MARK: Private methods
private extension ChatCore {
    func runAfterInit(closure: @escaping () -> Void) {
        guard initialized else {
            schedule(closure: closure)
            
            return
        }
        
        closure()
    }
    
    func schedule(closure: @escaping () -> Void) {
        cachedCalls.append(closure)
    }
}

// MARK: ChatNetworkServicingDelegate
extension ChatCore: ChatNetworkServicingDelegate {
    public func didFinishLoading(result: Result<Void, ChatError>) {

        switch result {
        case .success:
            initialized = true
            
            cachedCalls.forEach { call in
                call()
            }
            
            cachedCalls = []
        case .failure(let error):
            print(error)
        }
    }
}

// MARK: Background task management
import UIKit
private extension ChatCore {

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
