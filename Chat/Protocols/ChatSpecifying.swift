//
//  ChatSpecifying.swift
//  ChatApp
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

/// Essential chat functionality
public protocol ChatSpecifying {
    /// Chat models used in UI layer
    associatedtype UIModels: ChatUIModeling
    /// Networking layer
    associatedtype Networking
    /// Core layer
    associatedtype Core where Core.Networking == Networking,
        Core.UIModels.UIConversation == UIModels.UIConversation,
        Core.UIModels.UIMessage == UIModels.UIMessage,
        Core.UIModels.UIMessageSpecification == UIModels.UIMessageSpecification,
        Core.UIModels.UIUser == UIModels.UIUser
    /// UI layer
    associatedtype Interface: ChatInterfacing where Interface.UIService.Core == Core,
        Interface.UIService.Models.UIConversation == UIModels.UIConversation,
        Interface.UIService.Models.UIMessage == UIModels.UIMessage,
        Interface.UIService.Models.UIMessageSpecification == UIModels.UIMessageSpecification,
        Interface.UIService.Models.UIUser == UIModels.UIUser
    
    typealias UIConfiguration = Interface.UIService.Config
    typealias NetworkConfiguration = Networking.Config
    
    /// Function that returns an instance of UI for a given identifier
    /// When your app supports multiple windows you need to differentiate between multiple separate instances of UI
    ///
    /// - Parameter identifier: Unique identifier to identify a specific UI instance
    /// - Returns: Chat UI interface
    func interface(with identifier: ObjectIdentifier) -> Interface
    
    /// Continue running unfinished tasks. Core handles tasks to be finished when app gets into inactive state.
    ///
    /// - Parameter completion: Called upon finishing all stored(unfinished) background tasks
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void)
    
    /// Resends all unsent cached messages. Should be used in places when app goes to active state etc.
    func resendUnsentMessages()
    
    /// Sets current logged-in user
    ///
    /// - Parameters:
    ///   - userId: User identifier
    ///   - name: User's name
    ///   - imageUrl: User's profile image URL
    func setCurrentUser(userId: EntityIdentifier, name: String, imageUrl: URL?)
}
