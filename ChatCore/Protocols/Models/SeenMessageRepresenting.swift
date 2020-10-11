//
//  SeenMessageRepresenting.swift
//  ChatApp
//
//  Created by Daniel Pecher on 19/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol SeenMessageRepresenting {
    var messageId: EntityIdentifier { get }
    var seenAt: Date { get }
}
