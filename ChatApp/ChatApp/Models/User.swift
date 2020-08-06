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

struct User: UserRepresenting, Encodable {
    let id: EntityIdentifier
    let name: String
    let imageUrl: URL?
    let compatibility: Float?
}

extension User: ChatModel {}

extension User: Decodable {}
