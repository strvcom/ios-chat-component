//
//  MessageSpecification.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatUI

public enum MessageSpecification: MessageSpecificationForContent {
    case text(message: String)
    case image(image: UIImage)
    
    public static func specification(for messageType: ChatMessageType) -> MessageSpecification? {
        switch messageType {
        case .text(let text):
            return .text(message: text)
        case .photo(let item):
            return .image(image: item.image ?? item.placeholderImage)
        default:
            return nil
        }
    }
}

// MARK: - Cachable & Codable
extension MessageSpecification: Cachable {
    private enum CodingKeys: String, CodingKey {
      case message, image
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        if let message = try container.decodeIfPresent(String.self, forKey: .message) {
            self = .text(message: message)
        } else if let imageData = try container.decodeIfPresent(Data.self, forKey: .image), let image = UIImage(data: imageData) {
            self = .image(image: image)
        } else {
            let context = DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "MessageSpecification is missing content")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .text(let message):
          try container.encode(message, forKey: .message)
        case .image(let image):
            try container.encode(image.pngData(), forKey: .image)
        }
    }
}
