//
//  CachedMessageState.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/19/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - State of cached message
enum CachedMessageState: String, Codable {
    case stored
    case sending
}
