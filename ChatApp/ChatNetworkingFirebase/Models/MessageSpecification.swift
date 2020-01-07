//
//  MessageSpecification.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public enum MessageSpecification: MessageSpecifying {
    public static func specification(for data: Any) -> MessageSpecification? {
        
        switch data {
        case let data as String:
            return .text(message: data)
        case let data as UIImage:
            return .image(image: data)
        default:
            return nil
        }
    }
    
    case text(message: String)
    case image(image: UIImage)
}

extension MessageSpecification {
    // This method is asynchronous because of different than text messages
    // For example image messages require to upload the image binary first to get the image URL
    func toJSON(completion: ([String: Any]) -> Void) {
        // My user id that is stored somewhere
        let userId = "efeifjeife"
        
        switch self {
        case .text(let message):
            completion([
                Constants.Message.senderIdAttributeName: userId,
                Constants.Message.messageTypeAttributeName: "text",
                Constants.Message.dataAttributeName: [
                    "message": message
                ]
            ])
        case .image(_):
            // Upload image
            let imageUrl = "https://jefejiejejfejf"
            completion([
                Constants.Message.senderIdAttributeName: userId,
                Constants.Message.messageTypeAttributeName: "text",
                Constants.Message.dataAttributeName: [
                    "imageUrl": imageUrl
                ]
            ])
        }
    }
}
