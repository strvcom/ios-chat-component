//
//  ChatInterfacing.swift
//  Chat
//
//  Created by Jan on 01/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public protocol ChatInterfacing {
    /// Underlying `ChatUIServicing` implementation
    associatedtype UIService: ChatUIServicing
    /// Underlying `ChatUIServicing` implementation's delegate
    associatedtype Delegate where Delegate == UIService.Delegate
    
    /// Unique identifier
    var identifier: ObjectIdentifier { get }
    /// Instance of underlying `ChatUIServicing` implementation
    var uiService: UIService { get }
    /// Underlying `ChatUIServicing` implementation's delegate
    var delegate: Delegate? { get set }
    /// Underlying `ChatUIServicing` implementation's root view controller
    var rootViewController: UIViewController { get }
}
