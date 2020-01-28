//
//  MessageSpecification.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import Firebase
import FirebaseStorage

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
            completion(.success([
                Constants.Message.messageTypeAttributeName: Constants.Message.messageTypeText,
                Constants.Message.dataAttributeName: [
                    Constants.Message.dataAttributeNameText: message
                ],
                Constants.Message.sentAtAttributeName: Timestamp()
            ]))
        case .image(let image):
            send(image: image) { result in
                switch result {
                case .success(let imageUrl):
                    completion(.success([
                        Constants.Message.messageTypeAttributeName: Constants.Message.messageTypeImage,
                        Constants.Message.dataAttributeName: [
                            Constants.Message.dataAttributeNameImage: imageUrl
                        ],
                        Constants.Message.sentAtAttributeName: Timestamp()
                    ]))
                case .failure(let error):
                    completion(.failure(error))
                }
            }
        }
    }
}

private extension MessageSpecificationFirestore {
    func send(image: UIImage, completion: @escaping (Result<String, ChatError>) -> Void) {
        let storage = Storage.storage()
        let ref = storage.reference().child(UUID().uuidString)
        
        guard let data = image.pngData() ?? image.jpegData(compressionQuality: 1.0) else {
            completion(.failure(.internal(message: "No image data")))
            return
        }
        
        ref.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                completion(.failure(.networking(error: error)))
                return
            }
            
            ref.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(.networking(error: error)))
                }
                
                guard let imageUrl = url?.absoluteString else {
                    completion(.failure(.unexpectedState))
                    return
                }
                
                completion(.success(imageUrl))
            }
        }
    }
}
