//
//  User.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestoreSwift

public struct UserFirestore: UserRepresenting, Decodable {
    public let id: ChatIdentifier
    public let name: String
    public let imageUrl: URL?

    private enum CodingKeys: CodingKey {
        case id, name, imageUrl
    }
    
    public init(id: ChatIdentifier, name: String, imageUrl: URL?) {
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        self.id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue ?? ""
        self.name = try values.decode(String.self, forKey: .name)
        self.imageUrl = try values.decodeIfPresent(URL.self, forKey: .imageUrl)
    }
    
    public func reinit(withId id: ChatIdentifier) -> UserFirestore {
        return UserFirestore(id: id, name: self.name, imageUrl: self.imageUrl)
    }
}

