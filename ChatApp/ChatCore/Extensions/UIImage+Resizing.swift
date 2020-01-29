//
//  UIImage+Resizing.swift
//  ChatApp
//
//  Created by Daniel Pecher on 29/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIImage {
    public var optimized: UIImage {
        let width = size.width
        let height = size.height
        let scale = width / FileConstants.maxWidth
        
        guard width > FileConstants.maxWidth else {
            return self
        }
        
        let newSize = CGSize(
            width: FileConstants.maxWidth,
            height: CGFloat(ceil(FileConstants.maxWidth/width * height))
        )

        UIGraphicsBeginImageContextWithOptions(newSize, false, scale)
        defer { UIGraphicsEndImageContext() }
        draw(in: CGRect(origin: .zero, size: newSize))
        return UIGraphicsGetImageFromCurrentImageContext() ?? self
    }
}

private struct FileConstants {
    static let maxWidth: CGFloat = 1000
}
