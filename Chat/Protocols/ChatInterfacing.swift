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
    associatedtype UIService: ChatUIServicing
    associatedtype Delegate where Delegate == UIService.Delegate
    
    var identifier: ObjectIdentifier { get }
    var uiService: UIService { get }
    var delegate: Delegate? { get set }
    var rootViewController: UIViewController { get }
}
