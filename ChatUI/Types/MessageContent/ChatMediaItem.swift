//
//  ChatMediaItem.swift
//  ChatUI
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import MessageKit

public struct ChatMediaItem: MediaItem {
    public static let defaultSize: CGSize = CGSize(width: Constants.imageMessageSize.width, height: Constants.imageMessageSize.height)
    
    public var url: URL?
    public var image: UIImage?
    public var placeholderImage: UIImage
    public var size: CGSize
    
    public init(url: URL? = nil, image: UIImage? = nil, placeholderImage: UIImage = UIImage(), size: CGSize = Self.defaultSize) {
        self.url = url
        self.image = image
        self.placeholderImage = placeholderImage
        self.size = size
    }
}
