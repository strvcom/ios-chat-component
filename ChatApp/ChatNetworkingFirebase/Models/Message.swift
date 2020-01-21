//
//  Message.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import FirebaseFirestoreSwift
import FirebaseFirestore

public struct MessageFirestore: MessageRepresenting, Decodable {
    
    public let id: ChatIdentifier
    public let userId: ChatIdentifier
    public let sentAt: Date
    public let content: MessageFirebaseContent

    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case content = "data"
        case sentAt
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue else {
            throw ChatError.internal(message: "Missing documentID")
        }
        
        self.id = id
        self.userId = try values.decode(ChatIdentifier.self, forKey: .userId)
        self.sentAt = try values.decode(Timestamp.self, forKey: .sentAt).dateValue()
        self.content = try values.decode(MessageFirebaseContent.self, forKey: .content)
    }
}
