//
//  UserRepresenting+SenderType.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import MessageKit
import ChatCore

struct Sender: SenderType {
    let senderId: String
    let displayName: String
}

extension UserRepresenting {
    var sender: SenderType {
        Sender(senderId: id, displayName: name)
    }
}
