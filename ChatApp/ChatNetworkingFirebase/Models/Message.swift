//
//  Message.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public enum MessageContent {
    case text(message: String)
    case image(imageUrl: String)
}

public struct Message: MessageRepresenting, Decodable {
    public let id: ChatIdentifier
    public let userId: ChatIdentifier
    public let sentAt: Date
    public let content: MessageContent
    
    private enum CodingKeys: CodingKey {
        case id
        case userId
    }
    
    // TODO: Incomplete init
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try values.decode(ChatIdentifier.self, forKey: .id)
        self.userId = try values.decode(ChatIdentifier.self, forKey: .userId)
        
        // DUMMY DATA
        self.sentAt = Date()
        self.content = MessageContent.text(message: "Message")
    }
}
