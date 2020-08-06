//
//  ChatUIDelegate.swift
//  ChatUI
//
//  Created by Daniel Pecher on 28/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import UIKit

@objc public protocol ChatConversationsActionsDelegate: AnyObject {
    @objc optional func didTapOnEmptyListAction(in controller: UIViewController)
    func didSelectConversation(conversationId: EntityIdentifier, in controller: UIViewController)
}

@objc public protocol ChatMessagesActionsDelegate: AnyObject {
    @objc optional func didTapOnMoreButton(for conversationId: EntityIdentifier, in controller: UIViewController)
}

public protocol ChatConversationsList {
    var actionsDelegate: ChatConversationsActionsDelegate? { get set }
}

public typealias ChatConversationsListController = UIViewController & ChatConversationsList

public protocol ChatMessagesList {
    var actionsDelegate: ChatMessagesActionsDelegate? { get set }
}

public typealias ChatMessagesListController = UIViewController & ChatMessagesList
