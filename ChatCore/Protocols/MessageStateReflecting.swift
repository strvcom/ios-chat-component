//
//  MessageStateProviding.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/25/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Allows object to provide information about  message state
public protocol MessageStateReflecting {
    /// State of message for UI representation
    var state: MessageState { get set }
}
