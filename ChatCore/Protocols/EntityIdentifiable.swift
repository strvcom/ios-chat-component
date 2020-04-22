//
//  EntityIdentifiable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Used to identify any object
///
/// Discussion: This protocol originally inheritted from `Identifiable` but it caused runtime `BAD_ACCESS` errors on iOS 12
public protocol EntityIdentifiable {
    var id: EntityIdentifier { get }
}
