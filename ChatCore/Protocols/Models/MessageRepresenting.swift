//
//  Messagable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Minimal representation of a message used by the core.
public protocol MessageRepresenting: EntityIdentifiable {
    
    /// ID of the sender of this message
    var userId: EntityIdentifier { get }
    
    /// Date and time this message was sent at
    var sentAt: Date { get }
}
