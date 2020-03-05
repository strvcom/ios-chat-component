//
//  MessageSpecification.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public enum MessageSpecification: MessageSpecifying {
    case text(message: String)
    case image(image: UIImage)
}

extension MessageSpecification: Codable {
    private enum CodingKeys: String, CodingKey {
      case message, image
    }

    public init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)

        // default necessary init value
        self = .text(message: "")

        if let message = try container.decodeIfPresent(String.self, forKey: .message) {
            self = .text(message: message)
        }

        if let imageData = try container.decodeIfPresent(Data.self, forKey: .image), let image = UIImage(data: imageData) {
            self = .image(image: image)
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
