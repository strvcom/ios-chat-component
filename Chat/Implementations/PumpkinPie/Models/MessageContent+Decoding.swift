//
//  MessageContent+Decoding.swift
//  Chat
//
//  Created by Jan on 29/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatUI
import ChatCore

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
