//
//  ChatNetworking.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// swiftlint:disable type_name
/// This is the main and only protocol needed to be implemented when creating the network layer.
/// It's used by the core for all networking operations.
public protocol ChatNetworkServicing {
    associatedtype Config
    
    // Specific conversation type
    associatedtype C: ConversationRepresenting
    // Message description used for sending a message
    associatedtype MS: MessageSpecifying
    
    typealias M = C.Message
    typealias U = C.User

    /// Current user logged in to the app
    var currentUser: U? { get }
    
    /// Allow init network service and observe loading state at different places
    var didFinishedLoading: ((Result<Void, ChatError>) -> Void)? { get set }

    init(config: Config)
    
    /// Send a message to the specified conversation.
    ///
    /// - Parameters:
    ///   - message: Message data. Different from the model used for receiving messages.
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func send(message: MS, to conversation: ObjectIdentifier, completion: @escaping (Result<M, ChatError>) -> Void)
    
    /// Send a request to set `message` as the last seen message by current user
    ///
    /// - Parameters:
    ///   - message: Message to be set as last seen
    ///   - conversation: Target conversation
    func updateSeenMessage(_ message: M, in conversation: C)

    /// Creates a listener to conversations. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// - Parameters:
    ///   - pageSize: How many items to get at once
    ///   - listener: Identifer of an existing listener
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToConversations(pageSize: Int, listener: ListenerIdentifier, completion: @escaping (Result<[C], ChatError>) -> Void)
    
    //// This method asks for more data and calls the completion callback specified in `listenToConversations`
    func loadMoreConversations()
    
    /// Creates a listener to messages. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// - Parameters:
    ///   - id: Conversation ID
    ///   - pageSize: How many items to get at once
    ///   - listener: Identifier of an existing listener
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToMessages(conversation id: ObjectIdentifier, pageSize: Int, listener: ListenerIdentifier, completion: @escaping (Result<[M], ChatError>) -> Void)
    
    /// This method asks for more data and calls the completion callback specified in `listenToMessages`
    ///
    /// - Parameter id: conversation ID
    func loadMoreMessages(conversation id: ObjectIdentifier)

    /// Used to remove listeners when you no longer need to receive data.
    ///
    /// - Parameter listener: listener identifier obtained when creating a listener to conversations or messages
    func remove(listener: ListenerIdentifier)
}
