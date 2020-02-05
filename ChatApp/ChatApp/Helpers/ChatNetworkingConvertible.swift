//
//  ChatNetworkingConvertible.swift
//  ChatApp
//
//  Created by Mireya Orta on 1/16/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkFirebase
import ChatUI
import Foundation

extension ChatNetworkingConvertible where NetworkingModel: ChatUIConvertible, NetworkingModel.ChatUIModel == Self {

    public var networkingModel: NetworkingModel {
        return NetworkingModel(uiModel: self)
    }

}

// MessageSpecification
extension MessageSpecification {
    public func convert() -> MessageSpecificationFirestore {
        switch self {
        case .image(let image):
            return MessageSpecificationFirestore.image(image: image)
        case .text(let message):
            return MessageSpecificationFirestore.text(message: message)
        }
    }
}



