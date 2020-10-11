//
//  MessageContentImage.swift
//  ChatApp
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatUI

enum MessageContentImage: MessageMediaSpecifying, Equatable {
    case urlString(String)
    case image(UIImage)
    
    var media: ChatMediaItem {
        switch self {
        case let .urlString(urlString):
            return ChatMediaItem(url: URL(string: urlString))
        case let .image(image):
            return ChatMediaItem(image: image)
        }
    }
}
