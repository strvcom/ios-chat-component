//
//  MediaUploading.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol MediaUploading {
    func upload(content: MediaContent, on queue: DispatchQueue, completion: @escaping (Result<URL, ChatError>) -> Void)
}
