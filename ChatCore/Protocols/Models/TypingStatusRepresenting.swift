//
//  TypingStatusRepresenting.swift
//  ChatCore
//
//  Created by Daniel Pecher on 05/11/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol TypingStatusRepresenting where Self: EntityIdentifiable {
    var typingUsers: [EntityIdentifier: Bool] { get set }
}
