//
//  MessagesListDelegates.swift
//  ChatUI
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import UIKit

@objc public protocol MessagesListActionsDelegate: AnyObject {
    @objc optional func didTapOnMoreButton(for conversationId: EntityIdentifier, in controller: UIViewController)
}
