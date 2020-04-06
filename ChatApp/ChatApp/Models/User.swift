//
//  User.swift
//  ChatApp
//
//  Created by Tomas Cejka on 4/1/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - App user model
struct User: Encodable {
    let id: String
    let name: String
    let imageUrl: String?

    private enum CodingKeys: String, CodingKey {
        case name, imageUrl
    }
}
