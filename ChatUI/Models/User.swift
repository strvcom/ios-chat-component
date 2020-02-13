//
//  User.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public struct User: UserRepresenting {
    public let id: ChatIdentifier
    public let name: String
    public let imageUrl: URL?

    public init(id: ChatIdentifier, name: String, imageUrl: URL?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
}
