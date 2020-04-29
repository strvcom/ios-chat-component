//
//  JSONConvertible.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol JSONConvertible {
    var json: [String: Any] { get }
}
