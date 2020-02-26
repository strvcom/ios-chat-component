//
//  Messagable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol MessageRepresenting: Identifiable {
    var userId: Identifier { get }
    var sentAt: Date { get }
}
