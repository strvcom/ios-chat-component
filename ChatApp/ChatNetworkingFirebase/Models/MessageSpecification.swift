//
//  MessageSpecification.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import FirebaseFirestore

public enum MessageSpecificationFirestore: MessageSpecifying {
    case text(message: String)
    case image(image: UIImage)
}

extension MessageSpecificationFirestore {
    // This method is asynchronous because of different than text messages
    // For example image messages require to upload the image binary first to get the image URL
    func toJSON(completion: ([String: Any]) -> Void) {
        switch self {
        case .text(let message):
            completion([
                Constants.Message.messageTypeAttributeName: Constants.Message.messageTypeText,
                Constants.Message.dataAttributeName: [
                    Constants.Message.dataAttributeNameText: message
                ],
            ])
        case .image(_):
            // TODO: Upload image
            let imageUrl = "https://jefejiejejfejf"
            completion([
                Constants.Message.messageTypeAttributeName: Constants.Message.messageTypeImage,
                Constants.Message.dataAttributeName: [
                    Constants.Message.dataAttributeNameImage: imageUrl
                ],
            ])
        }
    }
}
