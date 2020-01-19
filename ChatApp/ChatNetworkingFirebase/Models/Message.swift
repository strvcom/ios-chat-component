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

public enum MessageFirebaseContent: Decodable {
    case text(message: String)
    case image(imageUrl: String)
    
    private enum CodingKeys: String, CodingKey {
        case text
        case image = "imageUrl"
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let message = try? values.decode(String.self, forKey: .text) {
            self = .text(message: message)
        } else if let imageUrl = try? values.decode(String.self, forKey: .image) {
            self = .image(imageUrl: imageUrl)
        } else {
            self = .text(message: "(no content)")
        }
    }
}

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
        
        self.id = try values.decode(DocumentID<String>.self, forKey: .id).wrappedValue ?? ""
        self.userId = try values.decode(ChatIdentifier.self, forKey: .userId)
        self.sentAt = try values.decode(Timestamp.self, forKey: .sentAt).dateValue()
        self.content = try values.decode(MessageFirebaseContent.self, forKey: .content)
    }
}
