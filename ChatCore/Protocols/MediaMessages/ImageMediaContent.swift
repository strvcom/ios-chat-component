//
//  MediaType.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

/// Default implementation of `MediaContent` that represents an image
public struct ImageMediaContent {
    /// Image object
    public let image: UIImage
    /// Closure for converting the image to data
    public let convertor: (UIImage) -> Data
    
    public init(image: UIImage, convertor: ((UIImage) -> Data)? = nil) {
        self.image = image
        
        if let convertor = convertor {
            self.convertor = convertor
        } else {
            self.convertor = { image in
                let optimized = image.optimized()
                
                guard let data = optimized.pngData() else {
                    fatalError("Cannot convert image to png data")
                }
                
                return data
            }
        }
    }
}

// MARK: Media Content
extension ImageMediaContent: MediaContent {
    public func normalizedData(completion: (Data) -> Void) {
        completion(
            convertor(image)
        )
    }
}
