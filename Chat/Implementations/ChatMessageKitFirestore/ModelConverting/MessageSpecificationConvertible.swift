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

extension MessageSpecification: ChatNetworkingConvertible {
    public typealias NetworkingModel = MessageSpecificationFirestore

    public init(networkingModel: MessageSpecificationFirestore) {
        switch networkingModel {
        case .image(let image):
            self = MessageSpecification.image(image: image)
        case .text(let message):
            self = MessageSpecification.text(message: message)
        }
    }

}

extension MessageSpecificationFirestore: ChatUIConvertible {
    public var uiModel: MessageSpecification {
        return MessageSpecification(networkingModel: self)
    }

    public init(uiModel: MessageSpecification) {
        switch uiModel {
        case .image(let image):
            self =  MessageSpecificationFirestore.image(image: image)
        case .text(let message):
            self = MessageSpecificationFirestore.text(message: message)
        }
    }
}
