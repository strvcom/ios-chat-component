//
//  Listener.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public typealias ChatListener = String

public extension ChatListener {
    static func generateIdentifier() -> ChatListener {
        return UUID().uuidString
    }
}
