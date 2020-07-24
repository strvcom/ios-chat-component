//
//  MessageContent.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import MessageKit

public typealias ChatMessageType = MessageKind

public protocol MessageSpecificationForContent: MessageSpecifying {
    static func specification(for messageType: ChatMessageType) -> Self?
}

public protocol MessageWithContent: MessageRepresenting {
    var kind: ChatMessageType { get }
}

struct Media: MediaItem {
    let placeholderImage: UIImage = UIImage()
    let size: CGSize = .zero
    let url: URL?
    let image: UIImage?
}
