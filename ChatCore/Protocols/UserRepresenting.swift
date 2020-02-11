//
//  Userable.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol UserRepresenting: ChatIdentifiable {
    var name: String { get }
    var imageUrl: URL? { get }
}
