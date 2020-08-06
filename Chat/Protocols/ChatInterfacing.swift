//
//  ChatInterfacing.swift
//  Chat
//
//  Created by Jan on 01/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatUI

public protocol ChatInterfacing {
    /// Underlying `ChatUIServicing` implementation
    associatedtype UIService: ChatUIServicing
    
    /// Unique identifier
    var identifier: ObjectIdentifier { get }
    /// Instance of underlying `ChatUIServicing` implementation
    var uiService: UIService { get }
    /// Underlying `ChatUIServicing` implementation's conversations view controller
    var conversationsViewController: ChatConversationsListController { get }
    /// Underlying `ChatUIServicing` implementation's messages view controller
    func messagesViewController(for conversationId: EntityIdentifier) -> ChatMessagesListController
}
