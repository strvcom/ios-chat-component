//
//  ChatNetworking.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// This is the main and only protocol needed to be implemented when creating the network layer.
/// It's used by the core for all networking operations.
public protocol ChatNetworkServicing {
    associatedtype Config
    associatedtype NetworkModels: ChatNetworkModeling
    associatedtype UserManager: UserManaging where UserManager.User == NetworkModels.NetworkUser

    // Shortcuts
    typealias NetworkConversation = NetworkModels.NetworkConversation
    typealias NetworkMessage = NetworkModels.NetworkMessage
    typealias NetworkMessageSpecification = NetworkModels.NetworkMessageSpecification

    init(config: Config, userManager: UserManager, mediaUploader: MediaUploading)

    /// Set current user
    ///
    /// - Parameters:
    ///   - id: User identifier
    func setCurrentUser(user id: EntityIdentifier)

    /// Initial loading of network service.
    ///
    /// - Parameters:
    ///   - completion: Called when network service is loaded or error appeared.
    func load(completion: @escaping (Result<Void, ChatError>) -> Void)

    /// Send a message to the specified conversation.
    ///
    /// - Parameters:
    ///   - message: Message data. Different from the model used for receiving messages.
    ///   - conversation: Conversation ID
    ///   - completion: Called upon receiving data (or encountering an error)
    func send(message: NetworkMessageSpecification, to conversation: EntityIdentifier, completion: @escaping (Result<EntityIdentifier, ChatError>) -> Void)

    /// Delete a message from the specified conversation
    ///
    /// - Parameters:
    ///   - message: Message data
    ///   - conversation: Conversation ID
    ///   - completion: Called upon deleting message (or encountering an error)
    func delete(message: NetworkMessage, from conversation: EntityIdentifier, completion: @escaping (Result<Void, ChatError>) -> Void)
    
    /// Send a request to set `message` as the last seen message by current user
    ///
    /// - Parameters:
    ///   - message: Identifier of a message to be set as last seen
    ///   - conversation: Identifier of a target conversation
    func updateSeenMessage(_ message: EntityIdentifier, in conversation: EntityIdentifier)

    /// Creates a listener to single conversation.
    ///
    /// - Parameters:
    ///   - conversation: Conversation id
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToConversation(conversation id: EntityIdentifier, completion: @escaping (Result<NetworkConversation, ChatError>) -> Void)

    /// Creates a listener to conversations. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// - Parameters:
    ///   - pageSize: How many items to get at once
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToConversations(pageSize: Int, completion: @escaping (Result<[NetworkConversation], ChatError>) -> Void)
    
    //// This method asks for more data and calls the completion callback specified in `listenToConversations`
    func loadMoreConversations()
    
    /// Creates a listener to messages. First set of data is received immediately by the completion callback. The same callback is called when requesting more data.
    ///
    /// - Parameters:
    ///   - id: Conversation ID
    ///   - pageSize: How many items to get at once
    ///   - completion: Called upon receiving data (or encountering an error)
    func listenToMessages(conversation id: EntityIdentifier, pageSize: Int, completion: @escaping (Result<[NetworkMessage], ChatError>) -> Void)
    
    /// This method asks for more data and calls the completion callback specified in `listenToMessages`
    ///
    /// - Parameter id: conversation ID
    func loadMoreMessages(conversation id: EntityIdentifier)

    /// Used to remove listeners when you no longer need to receive data.
    ///
    /// - Parameter listener: listener to be removed
    func remove(listener: Listener)
}
