//
//  ChatCoring.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
public protocol ChatCoreServicing {
    // Networking manager
    associatedtype Networking: ChatNetworkServicing
    associatedtype UIModels: ChatUIModels

    // Shortcuts
    typealias C = UIModels.CUI
    typealias M = UIModels.MUI
    typealias MS = UIModels.MSUI
    typealias U = UIModels.USRUI

    var currentUser: U? { get }

    init(networking: Networking)

    /// Send a message to the specified conversation.
    ///
    /// - Parameters:
    ///   - message: Message data. Different from the model used for receiving messages.
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func send(message: MS, to conversation: ObjectIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)
    
    /// Creates a listener to conversations. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// Returns a ListenerIdentifier instance which is later used to cancel the created listener.
    ///
    /// - Parameters:
    ///   - pageSize: How many items to get at once
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToConversations(pageSize: Int, completion: @escaping (Result<DataPayload<[C]>, ChatError>) -> Void) -> ListenerIdentifier
    
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
    func listenToMessages(conversation id: ObjectIdentifier, pageSize: Int, completion: @escaping (Result<DataPayload<[M]>, ChatError>) -> Void) -> ListenerIdentifier
    
    /// This method asks for more data and calls the completion callback specified in `listenToMessages`
    ///
    /// - Parameter id: conversation ID
    func loadMoreMessages(conversation id: ObjectIdentifier)
    
    /// Used to remove listeners when you no longer need to receive data.
    ///
    /// - Parameter listener: listener identifier obtained when creating a listener to conversations or messages
    func remove(listener: ListenerIdentifier)
    
    /// Send a request to set `message` as the last seen message by current user
    ///
    /// - Parameters:
    ///   - message: Message to be set as last seen
    ///   - conversation: Target conversation
    func updateSeenMessage(_ message: M, in conversation: ObjectIdentifier)
}

// MARK: Default page size
public extension ChatCoreServicing {
    func listenToMessages(conversation id: ObjectIdentifier, completion: @escaping (Result<DataPayload<[M]>, ChatError>) -> Void) -> ListenerIdentifier {
        listenToMessages(conversation: id, pageSize: Constants.defaultPageSize, completion: completion)
    }
    
    func listenToConversations(completion: @escaping (Result<DataPayload<[C]>, ChatError>) -> Void) -> ListenerIdentifier {
        listenToConversations(pageSize: Constants.defaultPageSize, completion: completion)
    }
}
