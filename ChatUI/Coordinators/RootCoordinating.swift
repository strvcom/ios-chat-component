//
//  RootCoordinating.swift
//  ChatUI
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

protocol RootCoordinating: AnyObject {
    associatedtype Core: ChatCoreServicing
    
    var conversationsViewController: ChatConversationsListController { get }
    func messagesViewController(for conversationId: EntityIdentifier) -> ChatMessagesListController
}
