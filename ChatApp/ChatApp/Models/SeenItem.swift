//
//  SeenItem.swift
//  ChatApp
//
//  Created by Jan on 10/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

struct SeenItem: SeenMessageRepresenting {
    let messageId: EntityIdentifier
    let seenAt: Date
}

extension SeenItem: Decodable {
    private enum CodingKeys: String, CodingKey {
        case messageId
        case seenAt = "timestamp"
    }
}
