//
//  MessageSpecificationConvertible.swift
//  ChatApp
//
//  Created by Mireya Orta on 2/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkingFirestore
import ChatUI
import Foundation

extension MessageSpecification: ChatModel {}

extension MessageSpecification: JSONConvertible {
    public var json: [String: Any] {
        switch self {
        case .text(let message):
            let data: [String: Any] = [
                "type": "text",
                "data": [
                    "text": message
                ]
            ]
            return data
        case .image(let image):
            let data: [String: Any] = [
                "type": "image",
                "data": [
                    "imageUrl": ImageMediaContent(image: image)
                ]
            ]
            return data
        }
    }
}
