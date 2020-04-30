//
//  User+Decoding.swift
//  ChatApp
//
//  Created by Jan on 30/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatUI
import ChatCore
import ChatNetworkingFirestore
import FirebaseFirestoreSwift

extension User: ChatModel {}

// TODO: Try to figure out how to infer this
extension User: Decodable {
    private enum CodingKeys: CodingKey {
        case id, name, imageUrl, compatibility
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        guard let id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue else {
            throw ChatError.incompleteDocument
        }
        
        let name = try values.decode(String.self, forKey: .name)
        let imageUrl = try values.decodeIfPresent(URL.self, forKey: .imageUrl)
        let compatibility = try values.decodeIfPresent(Float.self, forKey: .compatibility)

        self.init(id: id, name: name, imageUrl: imageUrl, compatibility: compatibility)
    }
}
