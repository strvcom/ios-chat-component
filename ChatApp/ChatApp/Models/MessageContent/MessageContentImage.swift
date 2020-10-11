//
//  MessageContentImage.swift
//  ChatApp
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatUI

enum MessageContentImage: ChatUIMessageMediaContent, Equatable {
    case urlString(String)
    case image(UIImage)
    
    var media: ChatUIMessageKitMediaItem {
        switch self {
        case let .urlString(urlString):
            return ChatUIMessageKitMediaItem(url: URL(string: urlString))
        case let .image(image):
            return ChatUIMessageKitMediaItem(image: image)
        }
    }
}
