//
//  Userable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Minimal representation of a user used by the core.
public protocol UserRepresenting: ObjectIdentifiable {
    
    /// Username
    var name: String { get }
    
    /// User's avatar URL
    var imageUrl: URL? { get }
}
