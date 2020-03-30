//
//  Axis.swift
//  ChatUI
//
//  Created by Daniel Pecher on 30/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

struct Axis: OptionSet {
    var rawValue: Int
    
    static let horizontal = Axis(rawValue: 1)
    static let vertical = Axis(rawValue: 2)
    
    static let all: Axis = [.horizontal, .vertical]
}
