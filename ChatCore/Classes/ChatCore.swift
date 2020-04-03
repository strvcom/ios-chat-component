//
//  ChatCore.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import UIKit

open class ChatCore<Networking: ChatNetworkServicing, Models: ChatUIModels>: ChatCoreServicing where
    
    // Specify that associated types
    // Conversation, Message (receive), MessageSpecifying (send) and User
    // of ChatNetworkServicing have to conform to `ChatUIConvertible`
    Networking.C: ChatUIConvertible,
    Networking.M: ChatUIConvertible,
    Networking.MS: ChatUIConvertible,
    Networking.U: ChatUIConvertible,

    // Extra requirements on models for this core implementation
    // supports message caching, message states, temp messages when sending
    Models.MSUI: Cachable,
    Models.MUI: MessageConvertible,
    Models.MUI: MessageStateReflecting,
    Models.MUI.MessageSpecification == Models.MSUI,

    Networking.U.ChatUIModel == Models.USRUI,
    Networking.C.ChatUIModel == Models.CUI,
    Networking.M.ChatUIModel == Models.MUI,
    Networking.MS.ChatUIModel == Models.MSUI {

    public typealias Networking = Networking
    public typealias UIModels = Models
    
    public typealias ConversationUI = Models.CUI
    public typealias MessageSpecifyingUI = Models.MSUI
    public typealias MessageUI = Models.MUI
    public typealias UserUI = Models.USRUI
    
    public typealias ConversationResult = Result<DataPayload<[ConversationUI]>, ChatError>
    public typealias MessagesResult = Result<DataPayload<[MessageUI]>, ChatError>

    // needs to be instantiated immediatelly to register scheduled tasks
    private let taskManager = TaskManager()
    private lazy var keychainManager = KeychainManager()
    private var closureThrottler: ListenerThrottler<MessageUI, MessagesResult>?
    private var reachabilityObserver: ReachabilityObserver?
    private var dataManagers = [Listener: DataManager]()
    
    private var conversationListeners = [
        Listener: [IdentifiableClosure<ConversationResult, Void>]
        ]()
    
    private var messagesListeners = [
        Listener: [IdentifiableClosure<MessagesResult, Void>]
        ]()
    
    private var networking: Networking
    
    private var messages = [ObjectIdentifier: DataPayload<[MessageUI]>]()
    private var conversations = DataPayload(data: [ConversationUI](), reachedEnd: false)

    @Required public private(set) var currentUser: UserUI?

    // current state observing
    public private(set) var currentState: ChatCoreState {
        didSet {
            stateChanged?(currentState)
        }
    }
    public var stateChanged: ((ChatCoreState) -> Void)?

    deinit {
        print("\(self) released")
        NotificationCenter.default.removeObserver(self)
    }

    // Here we can have also persistent storage manager
    // Or a manager for sending retry
    // Basically any networking agnostic business logic

    public required init (networking: Networking) {
        currentState = .initial
        self.networking = networking

        // hook to app did become active to resend messages
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(resendUnsentMessages), name: UIScene.didActivateNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(resendUnsentMessages), name: UIApplication.didBecomeActiveNotification, object: nil)
        }

        setReachabilityObserver()
        // in case core is initialized but cached messages got stuck in sending state e.g. app crashed
        restoreUnsentMessages()

        // avoid multiple listeners updates in short time
        closureThrottler = ListenerThrottler(closure: { [weak self] (payload, closures) in
            self?.callListenerClosures(payload: payload, closures: closures)
        })
    }

    // Needs to be in main class scope bc Extensions of generic classes cannot contain '@objc' members
    @objc open func resendUnsentMessages() {
        // at this place check user without crashying
        guard let userId = currentUser?.id else {
            return
        }

        let messages: [CachedMessage<MessageSpecifyingUI>] = keychainManager.unsentMessages()
        // take only messages which are not sending already
        // for unsent try to resend for failed add as temporary messages with failed state
        for message in messages {
            if message.userId != userId || message.state == .unsent || message.state == .failed {
                keychainManager.removeMessage(message: message)
            }

            if message.state == .unsent {
                send(message: message.content, to: message.conversationId, completion: { _ in })
            } else if message.state == .failed {
                handleTemporaryMessage(id: message.id, to: message.conversationId, with: .add(message.content, .failedToBeSend))
            }
        }
    }
}

// MARK: - Sending messages
extension ChatCore {
    open func send(message: MessageSpecifyingUI, to conversation: ObjectIdentifier,
                   completion: @escaping (Result<MessageUI, ChatError>) -> Void) {
        assert(currentUser != nil)

        // by default is cached message in sending state, similar as temporary message
        let cachedMessage = cacheMessage(message: message, from: conversation)
        handleTemporaryMessage(id: cachedMessage.id, to: conversation, with: .add(message))
        taskManager.run(attributes: [.backgroundTask, .afterInit, .backgroundThread, .retry(.finite())]) { [weak self] taskCompletion in
            let mess = Networking.MS(uiModel: message)
            self?.networking.send(message: mess, to: conversation) { result in
                switch result {
                case .success(let message):
                    _ = taskCompletion(.success)
                    self?.handleResultInCache(cachedMessage: cachedMessage, result: result)
                    self?.handleTemporaryMessage(id: cachedMessage.id, to: conversation, with: .remove)

                    completion(.success(message.uiModel))

                case .failure(let error):
                    if taskCompletion(.failure(error)) == .finished {
                        self?.handleResultInCache(cachedMessage: cachedMessage, result: result)
                        self?.handleTemporaryMessage(id: cachedMessage.id, to: conversation, with: .changeState(.failedToBeSend))
                        completion(.failure(error))
                    }
                }
            }
        }
    }
}

// MARK: - Deleting messages
extension ChatCore {
    open func delete(message: MessageUI, from conversation: ObjectIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void) {
        assert(currentUser != nil)

        taskManager.run(attributes: [.backgroundTask, .backgroundThread, .afterInit]) { [weak self] taskCompletion in
            let deleteMessage = Networking.M(uiModel: message)
            self?.networking.delete(message: deleteMessage, from: conversation) { result in
                self?.taskHandler(result: result, completion: taskCompletion)
                completion(result)
            }
        }
    }
}

// MARK: - Continue stored background tasks
public extension ChatCore {
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        assert(currentUser != nil)

        taskManager.runBackgroundCalls(completion: completion)
    }
}

// MARK: - Remove listeners
extension ChatCore {
    open func remove(listener: ListenerIdentifier) {
        removeListener(listener, from: &conversationListeners)
        removeListener(listener, from: &messagesListeners)
    }
}

// MARK: - Seen flag
extension ChatCore {
    open func updateSeenMessage(_ message: MessageUI, in conversation: ObjectIdentifier) {
        assert(currentUser != nil)

        guard let existingConversation = conversations.data.first(where: { conversation == $0.id }) else {
            print("Conversation with id \(conversation) not found")
            return
        }

        taskManager.run(attributes: [.backgroundTask, .backgroundThread, .afterInit]) { [weak self] _ in
            let seenMessage = Networking.M(uiModel: message)
            let conversation = Networking.C(uiModel: existingConversation)
            self?.networking.updateSeenMessage(seenMessage, in: conversation)
        }
    }
}

// MARK: - Listening to messages
extension ChatCore {
    open func listenToMessages(
        conversation id: ObjectIdentifier,
        pageSize: Int,
        completion: @escaping (MessagesResult) -> Void
    ) -> ListenerIdentifier {
        assert(currentUser != nil)

        let closure = IdentifiableClosure<MessagesResult, Void>(completion)
        let listener = Listener.messages(pageSize: pageSize, conversationId: id)
        
        if messagesListeners[listener] == nil {
            messagesListeners[listener] = []
        }
        
        messagesListeners[listener]?.append(closure)
        
        if let existingListeners = messagesListeners[listener], existingListeners.count > 1 {
            // A firebase listener for these arguments has already been registered, no need to register again
            defer {
                if let data = messages[id] {
                    closure.closure(.success(data))
                }
            }
            return closure.id
        }
        
        dataManagers[listener] = DataManager(pageSize: pageSize)
        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in
            
            guard let self = self else {
                return
            }
            
            self.networking.listenToMessages(conversation: id, pageSize: pageSize) { result in
                self.taskHandler(result: result, completion: taskCompletion)
                switch result {
                case .success(let messages):
                    // network returns at main thread
                    DispatchQueue.global(qos: .background).async {
                        self.dataManagers[listener]?.update(data: messages)
                        var converted = messages.compactMap({ $0.uiModel })
                        // add all temporary messages at original positions
                        let temporaryMessages = self.messages[id]?.data.filter { $0.state != .sent } ?? []
                        converted += temporaryMessages
                        converted.sort { $0.sentAt < $1.sentAt }

                        let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                        self.messages[id] = data
                        DispatchQueue.main.async {
                            self.closureThrottler?.handleClosures(interval: temporaryMessages.isEmpty ? 0 : 0.5, payload: data, listener: listener, closures: self.messagesListeners[listener] ?? [])
                        }
                    }

                case .failure(let error):
                    self.messagesListeners[listener]?.forEach {
                        $0.closure(.failure(error))
                    }
                }
            }})

        return closure.id
    }

    open func loadMoreMessages(conversation id: ObjectIdentifier) {
        assert(currentUser != nil)

        networking.loadMoreMessages(conversation: id)
    }
}

// MARK: - Listening to conversations
extension ChatCore {
    open func listenToConversations(
        pageSize: Int,
        completion: @escaping (ConversationResult) -> Void
    ) -> ListenerIdentifier {
        assert(currentUser != nil)

        let closure = IdentifiableClosure<ConversationResult, Void>(completion)
        let listener = Listener.conversations(pageSize: pageSize)

        // Add completion block
        if conversationListeners[listener] == nil {
            conversationListeners[listener] = []
        }
        conversationListeners[listener]?.append(closure)

        if let existingListeners = conversationListeners[listener], existingListeners.count > 1 {
            // A firebase listener for these arguments has already been registered, no need to register again
            defer { closure.closure(.success(conversations)) }
            return closure.id
        }

        dataManagers[listener] = DataManager(pageSize: pageSize)

        taskManager.run(attributes: [.afterInit, .backgroundThread], { [weak self] taskCompletion in

            guard let self = self else {
                return
            }

            self.networking.listenToConversations(pageSize: pageSize) { result in
                self.taskHandler(result: result, completion: taskCompletion)
                switch result {
                case .success(let conversations):

                    self.dataManagers[listener]?.update(data: conversations)
                    let converted = conversations.compactMap({ $0.uiModel })
                    let data = DataPayload(data: converted, reachedEnd: self.dataManagers[listener]?.reachedEnd ?? true)
                    self.conversations = data

                    // Call each closure registered for this listener
                    self.conversationListeners[listener]?.forEach {
                        $0.closure(.success(data))
                    }
                case .failure(let error):
                    self.conversationListeners[listener]?.forEach {
                        $0.closure(.failure(error))
                    }
                }
            }
        })

        return closure.id
    }

    open func loadMoreConversations() {
        assert(currentUser != nil)

        networking.loadMoreConversations()
    }
}

// MARK: - Temporary messages
private extension ChatCore {
    // Actions over temporary messages
    enum TemporaryMessageAction {
        case add(MessageSpecifyingUI, MessageState = .sending)
        case remove
        case changeState(MessageState)
    }

    func handleTemporaryMessage(id: ObjectIdentifier, to conversation: ObjectIdentifier, with action: TemporaryMessageAction) {
        assert(currentUser != nil)

        // find all listeners for messages and same conversationId
        let listeners = messagesListeners.filter({ (key, _) -> Bool in
            if case let .messages(_, conversationId) = key {
                return conversation == conversationId
            }
            return false
        })

        // check if listeners and data payload are set
        guard !listeners.isEmpty else {
            return
        }
        guard let messagesPayload = messages[conversation] else {
            return
        }

        var newData: [MessageUI]
        switch action {
        case .remove:
            newData = messagesPayload.data.filter { $0.id != id }
        case .add(let message, let state):
            let temporaryMessage = MessageUI(id: id, userId: $currentUser.id, messageSpecification: message, state: state)
            newData = messagesPayload.data
            newData.append(temporaryMessage)
        case .changeState(let state):
            newData = messagesPayload.data
            if let index = newData.firstIndex(where: { $0.id == id }) {
                var message = newData[index]
                message.state = state
                newData[index] = message
            }
        }

        let newPayload = DataPayload(data: newData, reachedEnd: messagesPayload.reachedEnd)
        self.messages[conversation] = newPayload

        // Call each closure registered for this listener
        listeners.forEach { (listener, closures) in
            closureThrottler?.handleClosures(payload: newPayload, listener: listener, closures: closures)
        }
    }

    func callListenerClosures(payload: DataPayload<[MessageUI]>, closures: [IdentifiableClosure<MessagesResult, Void>]) {
        closures.forEach {
            $0.closure(.success(payload))
        }
    }
}

// MARK: - Caching messages
private extension ChatCore {
    func cacheMessage<T: MessageSpecifying & Cachable>(message: T, from conversation: ObjectIdentifier, state: CachedMessageState = .sending) -> CachedMessage<T> {

        // store to keychain for purpose message wont send
        let cachedMessage = CachedMessage(content: message, conversationId: conversation, userId: $currentUser.id, state: state)
        keychainManager.storeUnsentMessage(cachedMessage)

        return cachedMessage
    }

    func handleResultInCache<T: MessageSpecifying & Cachable, U: MessageRepresenting>(cachedMessage: CachedMessage<T>, result: Result<U, ChatError>) {
        // when sucessfully sent remove from cache
        // in case of network error restore the message with stored state
        // other than network error set status as failed
        switch result {
        case .success:
            keychainManager.removeMessage(message: cachedMessage)
        case .failure(let error):
            if case .networking = error {
                changeCachedMessage(cachedMessage: cachedMessage, to: .unsent)
            } else {
                changeCachedMessage(cachedMessage: cachedMessage, to: .failed)
            }
        }
    }

    func restoreUnsentMessages() {
        let messages: [CachedMessage<MessageSpecifyingUI>] = keychainManager.unsentMessages()
        // for case app was closed while sending
        for message in messages where message.state == .sending {
            changeCachedMessage(cachedMessage: message, to: .unsent)
        }
    }

    func changeCachedMessage<T: MessageSpecifying & Cachable>(cachedMessage: CachedMessage<T>, to state: CachedMessageState) {
        var changedCachedMessage = cachedMessage
        changedCachedMessage.changeState(state: state)
        // remove original one, store new one
        keychainManager.removeMessage(message: cachedMessage)
        keychainManager.storeUnsentMessage(changedCachedMessage)
    }
}

// MARK: - ChatNetworkServicing load state observing, helper methods
private extension ChatCore {
    func loadNetworkService() {
        currentState = .loading
        taskManager.run(attributes: [.retry(.infinite), .backgroundThread], { [weak self] taskCompletion in
            self?.networking.load(completion: { result in
                self?.taskHandler(result: result, completion: taskCompletion)
                if case .success = result {
                    self?.currentState = .connected
                    self?.taskManager.initialized = true
                }
            })
        })
    }
    
    func removeListener<T>(
        _ listenerId: ListenerIdentifier,
        from listeners: inout [Listener: [IdentifiableClosure<T, Void>]]
    ) {
        listeners.forEach { (listener, closures) in
            closures.forEach { _ in
                listeners[listener] = listeners[listener]?.filter { $0.id != listenerId }
            }
            
            // If there are no more closures registered for this set of arguments, remove networking listener and data manager
            if listeners[listener]?.isEmpty ?? true {
                networking.remove(listener: listener)
                dataManagers[listener] = nil
            }
        }
    }

    // This method wraps result from task manager in cases when no need of value
    // Value has meaning in case when we wanna send completion after retry etc
    // This happenes eg in send message method, after task manager finishes than completion is called at method caller
    func taskHandler<T>(result: Result<T, ChatError>, completion: (TaskManager.TaskCompletionResult) -> TaskManager.TaskCompletionState) {
        switch result {
        case .success:
            _ = completion(.success)
        case .failure(let error):
            _ = completion(.failure(error))
        }
    }
}

// MARK: - Setup reachability observer
private extension ChatCore {
    func setReachabilityObserver() {
        // observe network changes
        reachabilityObserver = ReachabilityObserver(reachabilityChanged: { [weak self] state in
            guard self?.currentState != .loading else {
                return
            }
            switch state {
            case .reachable:
                self?.currentState = .connected
            case .unreachable:
                self?.currentState = .connecting
            }
        })
    }
}

// MARK: - User management
extension ChatCore {
    open func setCurrentUser(user: UserUI) {
        currentUser = user
        networking.setCurrentUser(user: user.id)
        loadNetworkService()
    }
}
