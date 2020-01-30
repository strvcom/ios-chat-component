//
//  UIImage+Resizing.swift
//  ChatApp
//
//  Created by Daniel Pecher on 29/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIImage {
    public func optimized(maxSize: CGFloat = 1000) -> UIImage {
        let width = size.width
        let height = size.height
        let scale = width / maxSize
        let isPortrait = width < height
        var newSize: CGSize
        
        if isPortrait {
            if height <= maxSize {
                return self
            }
            
            newSize = CGSize(
                width: CGFloat(ceil(maxSize/height * width)),
                height: maxSize
            )
        } else {
            if width <= maxSize {
                return self
            }
            
            newSize = CGSize(
                width: maxSize,
                height: CGFloat(ceil(maxSize/width * height))
            )
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
