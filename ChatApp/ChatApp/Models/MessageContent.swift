//
//  MessageContent.swift
//  ChatApp
//
//  Created by Jan on 03/08/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public enum MessageContent {
    case text(message: String)
    case image(imageUrl: String)
}

// TODO: Try to figure out how to infer this
extension MessageContent: Decodable {
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
            throw ChatError.incompleteDocument
        }
    }
}
