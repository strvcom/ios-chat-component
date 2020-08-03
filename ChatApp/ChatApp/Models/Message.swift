//
//  MessageKitType.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatUI
import Foundation
import MessageKit
import FirebaseFirestore
import FirebaseFirestoreSwift

public struct Message: MessageType, MessageWithContent, MessageConvertible, MessageStateReflecting {
    public var userId: EntityIdentifier

    public var sentAt: Date

    public var id: EntityIdentifier
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
    public var state: MessageState

    public init(id: EntityIdentifier, userId: EntityIdentifier, messageSpecification: MessageSpecification, state: MessageState = .sending) {
        self.sentAt = Date()
        self.sentDate = Date()
        self.messageId = id
        self.id = id
        self.sender = User(id: userId, name: "", imageUrl: nil, compatibility: 0)
        self.userId = userId

        switch messageSpecification {
        case .text(let message):
            self.kind = .text(message)
        case .image(let image):
            // FIXME: Update zero size
            let imageItem = ImageItem(
                url: nil,
                image: image,
                placeholderImage: UIImage(),
                size: CGSize.zero
            )
            self.kind = .photo(imageItem)
        }

        self.state = state
    }

    public init(id: EntityIdentifier, userId: EntityIdentifier, sentAt: Date, content: MessageContent) {
        self.sender = User(id: userId, name: "", imageUrl: nil, compatibility: 0)
        self.messageId = id
        self.sentDate = sentAt
        
        switch content {
        case .text(let message):
            self.kind = .text(message)
        case .image(let imageUrl):
            // FIXME: Update zero size
            let imageItem = ImageItem(
                url: URL(string: imageUrl),
                image: nil,
                placeholderImage: UIImage(),
                size: CGSize.zero
            )
            self.kind = .photo(imageItem)
        }
        
        self.sentAt = sentAt
        self.userId = userId
        self.id = id
        self.state = .sent
    }
}

extension Message: ChatModel {}

// TODO: Try to figure out how to infer this
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
