//
//  ConversationsListViewController.swift
//  ChatApp
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public protocol ConversationsList {
    var actionsDelegate: ConversationsListActionsDelegate? { get set }
}

public typealias ConversationsListViewController = UIViewController & ConversationsList
