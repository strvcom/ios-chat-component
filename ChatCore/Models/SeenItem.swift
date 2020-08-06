//
//  SeenItem.swift
//  ChatApp
//
//  Created by Daniel Pecher on 19/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public struct SeenItem {
    public let messageId: EntityIdentifier
    public let seenAt: Date
    
    public init(messageId: EntityIdentifier, seenAt: Date) {
        self.messageId = messageId
        self.seenAt = seenAt
    }
}
