//
//  MediaType.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

/// Default implementation of `MediaContent` that represents an image
struct ImageMediaContent {
    /// Image object
    let image: UIImage
    /// Closure for converting the image to data
    let convertor: (UIImage) -> Data
    
    init(image: UIImage, convertor: ((UIImage) -> Data)? = nil) {
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
    func dataForUpload(completion: (Data) -> Void) {
        completion(
            convertor(image)
        )
    }
}
