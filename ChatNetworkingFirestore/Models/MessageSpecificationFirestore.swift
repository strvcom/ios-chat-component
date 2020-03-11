//
//  MessageSpecification.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public enum MessageSpecificationFirestore: MessageSpecifying {
    case text(message: String)
    case image(image: UIImage)
}

extension MessageSpecificationFirestore {
    // This method is asynchronous because of different than text messages
    // For example image messages require to upload the image binary first to get the image URL
    func toJSON(completion: @escaping (Result<[String: Any], ChatError>) -> Void) {
        switch self {
        case .text(let message):
            let data: [String: Any] = [
                Constants.Message.messageTypeAttributeName: Constants.Message.messageTypeText,
                Constants.Message.dataAttributeName: [
                    Constants.Message.dataAttributeNameText: message
                ]
            ]
            completion(.success(data))
        case .image(let image):
            ImageUploader().upload(image: image) { result in
                switch result {
                case .success(let imageUrl):
                    let data: [String: Any] = [
                        Constants.Message.messageTypeAttributeName: Constants.Message.messageTypeImage,
                        Constants.Message.dataAttributeName: [
                            Constants.Message.dataAttributeNameImage: imageUrl
                        ]
                    ]
                    completion(.success(data))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}
