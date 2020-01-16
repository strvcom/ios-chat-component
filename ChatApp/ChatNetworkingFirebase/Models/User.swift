//
//  User.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public struct UserFirestore: UserRepresenting, Decodable {
    public let id: ChatIdentifier
    public let name: String
    public let imageUrl: URL?

    private enum CodingKeys: CodingKey {
        case id
    }

    // TODO: Incomplete init
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(ChatIdentifier.self, forKey: .id)

        // DUMMY DATA
        self.name = "John Smith"
        self.imageUrl = nil
    }
}

