//
//  MesageContent.swift
//  ChatApp
//
//  Created by Daniel Pecher on 20/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

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
            throw ChatError.internal(message: "No message content")
        }
    }
}
