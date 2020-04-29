//
//  MessageConvertible.swift
//  ChatApp
//
//  Created by Mireya Orta on 2/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkingFirestore
import ChatUI
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

extension Message: ChatModel {}

extension Message: Decodable {
    private enum CodingKeys: String, CodingKey {
        case id
        case userId
        case content = "data"
        case sentAt
    }

    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        guard let id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue else {
            throw ChatError.incompleteDocument
        }
        
        let userId = try values.decode(EntityIdentifier.self, forKey: .userId)
        let sentAt = try values.decode(Timestamp.self, forKey: .sentAt).dateValue()
        let content = try values.decode(MessageContent.self, forKey: .content)
        
        self.init(id: id, userId: userId, sentAt: sentAt, content: content)
    }
}
