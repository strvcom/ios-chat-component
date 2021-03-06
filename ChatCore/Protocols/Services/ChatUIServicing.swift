//
//  ChatUIServicing.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// This protocol can be used to make sure any main class is initialized with ChatCore that implements `ChatCoreServicing`.
public protocol ChatUIServicing {
    associatedtype Core: ChatCoreServicing
    associatedtype Models: ChatUIModeling
    associatedtype Config
    
    /// Set log level for `UI` service
    var logLevel: ChatLogLevel { get set }

    init(core: Core, config: Config)
}
