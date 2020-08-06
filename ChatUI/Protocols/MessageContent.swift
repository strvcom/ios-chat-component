//
//  MessageContent.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import MessageKit

public typealias ChatUIMessageKitKind = MessageKind

public protocol ChatUIMessageContent {
    var kind: ChatUIMessageKitKind { get }
}

public struct ChatUIMessageKitMediaItem: MediaItem {
    public static let defaultSize: CGSize = CGSize(width: Constants.imageMessageSize.width, height: Constants.imageMessageSize.height)
    
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
    
    public init(url: URL? = nil, image: UIImage? = nil, placeholderImage: UIImage = UIImage(), size: CGSize = Self.defaultSize) {
        self.url = url
        self.image = image
        self.placeholderImage = placeholderImage
        self.size = size
    }
}

public protocol ChatUIMessageMediaContent {
    var media: ChatUIMessageKitMediaItem { get }
}

public protocol MessageSpecificationForContent: MessageSpecifying {
    static func specification(for messageKitKind: ChatUIMessageKitKind) -> Self?
}

public protocol MessageWithContent: MessageRepresenting, MessageType {
    associatedtype Content: ChatUIMessageContent
    
    var content: Content { get }
}

struct MessageUser: SenderType {
    let senderId: String
    let displayName: String
}

public extension MessageWithContent {
    var sender: SenderType {
        // TODO: Sender name
        MessageUser(senderId: self.userId, displayName: "")
    }
    
    var sentDate: Date {
        sentAt
    }
    
    var messageId: String {
        id
    }
    
    var kind: MessageKind {
        content.kind
    }
}

struct Media: MediaItem {
    let placeholderImage: UIImage = UIImage()
    let size: CGSize = .zero
    let url: URL?
    let image: UIImage?
}
