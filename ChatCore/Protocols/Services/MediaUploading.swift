//
//  MediaUploading.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// Defines service for uploading media content e.g. images, videos, etc.
public protocol MediaUploading {
    /// Upload media content
    /// - Parameters:
    ///   - content: Media content that conforms to `MediaContent` protocol
    ///   - queue: `DispatchQueue` on which the `completion` should be called
    ///   - completion: Closure that is called on completion or error
    func upload(content: MediaContent, path: String?, on queue: DispatchQueue, completion: @escaping (Result<URL, ChatError>) -> Void)
}
