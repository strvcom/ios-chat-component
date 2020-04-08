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
    public let id: EntityIdentifier
    public let name: String
    public let imageUrl: URL?
    public let compatibility: Float?

    public init(id: EntityIdentifier, name: String, imageUrl: URL?, compatibility: Float? = nil) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
        self.compatibility = compatibility
    }
}

// MARK: MessageKit sender type
extension User: SenderType {
    public var senderId: String {
        id
    }

    public var displayName: String {
        name
    }
}
