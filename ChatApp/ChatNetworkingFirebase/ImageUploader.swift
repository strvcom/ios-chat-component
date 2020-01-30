//
//  ImageUploader.swift
//  ChatNetworkFirebase
//
//  Created by Daniel Pecher on 29/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import FirebaseStorage

struct ImageUploader {
    func upload(image: UIImage, completion: @escaping (Result<String, ChatError>) -> Void) {
        let storage = Storage.storage()
        let ref = storage.reference().child(UUID().uuidString)
        let optimized = image.optimized()
        
        guard let data = optimized.pngData() ?? optimized.jpegData(compressionQuality: 1.0) else {
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
