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

public class FirestoreMediaUploader: MediaUploading {
    private lazy var storage = Storage.storage()
    
    public init() {}
    
    public func upload(content: MediaContent, on queue: DispatchQueue, completion: @escaping (Result<URL, ChatError>) -> Void) {
        content.normalizedData { [weak self] data in
            self?.upload(data: data, completion: { result in
                queue.async {
                    completion(result)
                }
            })
        }
    }
    
    private func upload(data: Data, completion: @escaping (Result<URL, ChatError>) -> Void) {
        let ref = storage.reference().child(UUID().uuidString)
        
        ref.putData(data, metadata: nil) { (_, error) in
            if let error = error {
                completion(.failure(.networking(error: error)))
                return
            }
            
            ref.downloadURL { (url, error) in
                if let error = error {
                    completion(.failure(.networking(error: error)))
                }
                
                guard let url = url else {
                    completion(.failure(.unexpectedState))
                    return
                }
                
                completion(.success(url))
            }
        }
    }
}
