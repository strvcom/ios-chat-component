//
//  MessagesListViewController.swift
//  ChatApp
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public protocol MessagesList {
    var actionsDelegate: MessagesListActionsDelegate? { get set }
}

public typealias MessagesListViewController = UIViewController & MessagesList
