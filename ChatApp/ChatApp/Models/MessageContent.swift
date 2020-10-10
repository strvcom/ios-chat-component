//
//  MessageContent.swift
//  ChatApp
//
//  Created by Jan on 03/08/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatUI
import UIKit

enum MessageContentImage: ChatUIMessageMediaContent, Equatable {
    case urlString(String)
    case image(UIImage)
    
    var media: ChatUIMessageKitMediaItem {
        switch self {
        case let .urlString(urlString):
            return ChatUIMessageKitMediaItem(url: URL(string: urlString))
        case let .image(image):
            return ChatUIMessageKitMediaItem(image: image)
        }
    }
}

enum MessageContentText: ChatUIMessageContent, Equatable {
    case simple(String)
    case attributed(NSAttributedString)
    
    var kind: ChatUIMessageKitKind {
        switch self {
        case let .simple(text):
            return .text(text)
        case let .attributed(attributed):
            return .attributedText(attributed)
        }
    }
}

extension MessageContent: ChatModel {}

enum MessageContent: ChatUIMessageContent, MessageSpecificationForContent {
    case text(MessageContentText)
    case image(MessageContentImage)
    
    var kind: ChatUIMessageKitKind {
        switch self {
        case let .text(content):
            return content.kind
        case let .image(content):
            return .photo(content.media)
        }
    }
    
    static func specification(for messageType: ChatUIMessageKitKind) -> MessageContent? {
        switch messageType {
        case let .text(text):
            return .text(.simple(text))
        case let .attributedText(text):
            return .text(.attributed(text))
        case .photo(let item):
            if let image = item.image {
                return .image(.image(image))
            } else if let url = item.url?.absoluteString {
                return .image(.urlString(url))
            } else {
                return nil
            }
        default:
            return nil
        }
    }
}

// TODO: Try to figure out how to infer this
extension MessageContent: Cachable {
    private enum CodingKeys: String, CodingKey {
        case text
        case image
        case imageUrl
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let message = try? values.decode(String.self, forKey: .text) {
            self = .text(.simple(message))
        } else if let imageUrl = try? values.decode(String.self, forKey: .imageUrl) {
            self = .image(.urlString(imageUrl))
        } else if let imageData = try? values.decode(Data.self, forKey: .image), let image = UIImage(data: imageData) {
            self = .image(.image(image))
        } else {
            throw ChatError.incompleteDocument
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        switch self {
        case let .text(content):
          let message: String
          switch content {
          case let .simple(text):
              message = text
          case let .attributed(text):
              message = text.string
          }
          try container.encode(message, forKey: .text)
        case let .image(content):
            switch content {
            case let .image(image):
                try container.encode(image.pngData(), forKey: .image)
            case let .urlString(url):
                try container.encode(url, forKey: .imageUrl)
            }
        }
    }
}

// TODO: Try to figure out how to infer this
extension MessageContent: JSONConvertible {
    public var json: [String: Any] {
        switch self {
        case let .text(content):
            let message: String
            switch content {
            case let .simple(text):
                message = text
            case let .attributed(text):
                message = text.string
            }
            let data: [String: Any] = [
                "type": "text",
                "data": [
                    "text": message
                ]
            ]
            return data
        case let .image(content):
            let imageUrl: Any
            switch content {
            case let .urlString(url):
                imageUrl = url
            case let .image(image):
                imageUrl = ImageMediaContent(image: image)
            }
            let data: [String: Any] = [
                "type": "image",
                "data": [
                    "imageUrl": imageUrl
                ]
            ]
            return data
        }
    }
}
