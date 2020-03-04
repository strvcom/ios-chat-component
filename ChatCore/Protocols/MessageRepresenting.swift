//
//  Messagable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Minimal representation of a message used by the core.
public protocol MessageRepresenting: ObjectIdentifiable {
    var userId: ObjectIdentifier { get }
    var sentAt: Date { get }
}
