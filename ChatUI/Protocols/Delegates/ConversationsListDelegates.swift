//
//  ConversationsListDelegates.swift
//  ChatUI
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import UIKit

@objc public protocol ConversationsListActionsDelegate: AnyObject {
    @objc optional func didTapOnEmptyListAction(in controller: UIViewController)
    func didSelectConversation(conversationId: EntityIdentifier, in controller: UIViewController)
}
