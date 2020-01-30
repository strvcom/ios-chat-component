//
//  UIImage+Resizing.swift
//  ChatApp
//
//  Created by Daniel Pecher on 29/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIImage {
    public func optimized(maxWidth: CGFloat = 1000) -> UIImage {
        let width = size.width
        let height = size.height
        let scale = width / maxWidth
        
        guard width > maxWidth else {
            return self
        }
        
        let newSize = CGSize(
            width: maxWidth,
            height: CGFloat(ceil(maxWidth/width * height))
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}
