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
import FirebaseFirestoreSwift

public struct User: UserRepresenting, Encodable {
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
    
    public func encode(to encoder: Encoder) throws {
        // FIXME: Implement encoding
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
