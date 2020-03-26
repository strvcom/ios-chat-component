//
//  User.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import MessageKit

public struct User: UserRepresenting {
    public let id: ObjectIdentifier
    public let name: String
    public let imageUrl: URL?
    public let compatibility: Float

    public init(id: ObjectIdentifier, name: String, imageUrl: URL?, compatibility: Float) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.compatibility = compatibility
    }
}

extension User: SenderType {
    public var senderId: String {
        id
    }
    
    public var displayName: String {
        name
    }
}
