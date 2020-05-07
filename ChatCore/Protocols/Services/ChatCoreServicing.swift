//
//  ChatCoring.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import UIKit

public protocol ChatCoreServicing {
    // Networking manager
    associatedtype Networking: ChatNetworkServicing
    associatedtype UIModels: ChatUIModeling

    // Shortcuts
    typealias CoreConversation = UIModels.UIConversation
    typealias CoreMessage = UIModels.UIMessage
    typealias CoreMessageSpecification = UIModels.UIMessageSpecification
    typealias CoreUser = UIModels.UIUser
    
    /// Current user logged in to the app
    var currentUser: CoreUser { get }

    /// Current state of chat core and its observing
    var currentState: ChatCoreState { get }
    var stateChanged: ((ChatCoreState) -> Void)? { get set }

    init(networking: Networking)

    /// Sets current user for chat core
    ///
    /// - Parameters:
    ///   - user: Current user
    func setCurrentUser(user: CoreUser)

    /// Continue running unfinished tasks. Core handles tasks to be finished when app gets into inactive state.
    ///
    /// - Parameters:
    ///   - completion: Called upon finishing all stored(unfinished) background tasks
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void)

    /// Resends all unsent cached messages. Should be used in places when app goes to active state etc.
    ///
    func resendUnsentMessages()

    /// Send a message to the specified conversation.
    ///
    /// - Parameters:
    ///   - message: Message data. Different from the model used for receiving messages.
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func send(message: CoreMessageSpecification, to conversation: EntityIdentifier, completion: @escaping (Result<CoreMessage, ChatError>) -> Void)

    /// Delete a message
    ///
    /// - Parameters:
    ///   - message: Message data
    ///   - conversation: Conversation ID
    ///   - completion: Called upon deleting message (or encountering an error)
    func delete(message: CoreMessage, from conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void)

    /// Creates a listener to conversation. First set of data is received immediately by the completion callback.
    ///
    /// Returns a ListenerIdentifier instance which is later used to cancel the created listener.
    ///
    /// - Parameters:
    ///   - conversation: Conversation id
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToConversation(conversation id: EntityIdentifier, completion: @escaping (Result<CoreConversation, ChatError>) -> Void) -> ListenerIdentifier

    /// Creates a listener to conversations. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// Returns a ListenerIdentifier instance which is later used to cancel the created listener.
    ///
    /// - Parameters:
    ///   - pageSize: How many items to get at once
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToConversations(pageSize: Int, completion: @escaping (Result<DataPayload<[CoreConversation]>, ChatError>) -> Void) -> ListenerIdentifier
    
    /// This method asks for more data and calls the completion callback specified in `listenToConversations`
    func loadMoreConversations()
    
    /// Creates a listener to messages. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// Returns a ListenerIdentifier instance which is later used to cancel the created listener.
    ///
    /// - Parameters:
    ///   - id: Conversation ID
    ///   - pageSize: How many items to get at once
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToMessages(conversation id: EntityIdentifier, pageSize: Int, completion: @escaping (Result<DataPayload<[CoreMessage]>, ChatError>) -> Void) -> ListenerIdentifier
    
    /// This method asks for more data and calls the completion callback specified in `listenToMessages`
    ///
    /// - Parameter id: conversation ID
    func loadMoreMessages(conversation id: EntityIdentifier)
    
    /// Used to remove listeners when you no longer need to receive data.
    ///
    /// - Parameter listener: listener identifier obtained when creating a listener to conversations or messages
    func remove(listener: ListenerIdentifier)
    
    /// Send a request to set `message` as the last seen message by current user
    ///
    /// - Parameters:
    ///   - message: Message to be set as last seen
    ///   - conversation: Target conversation
    func updateSeenMessage(_ message: CoreMessage, in conversation: EntityIdentifier)
}

// MARK: Default page size
public extension ChatCoreServicing {
    func listenToMessages(conversation id: EntityIdentifier, completion: @escaping (Result<DataPayload<[CoreMessage]>, ChatError>) -> Void) -> ListenerIdentifier {
        listenToMessages(conversation: id, pageSize: Constants.defaultPageSize, completion: completion)
    }
    
    func listenToConversations(completion: @escaping (Result<DataPayload<[CoreConversation]>, ChatError>) -> Void) -> ListenerIdentifier {
        listenToConversations(pageSize: Constants.defaultPageSize, completion: completion)
    }
}
