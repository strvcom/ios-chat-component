//
//  MessageConvertible.swift
//  ChatApp
//
//  Created by Mireya Orta on 2/5/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatCore
import ChatNetworkFirebase
import ChatUI
import Foundation

extension MessageKitType: ChatNetworkingConvertible {

    public typealias NetworkingModel = MessageFirestore
}

extension MessageFirestore: ChatUIConvertible {

    public var uiModel: MessageKitType {
        var content = MessageContent.text(message: "")

        switch self.content {
        case .image(let imageUrl):
            content = .image(imageUrl: imageUrl)
        case .text(let message):
            content = .text(message: message)
        }

        return MessageKitType(id: self.id, userId: self.userId, sentAt: self.sentAt, content: content)
    }

    public init(uiModel: MessageKitType) {
        self.init(id: uiModel.id, userId: uiModel.userId, sentAt: uiModel.sentDate, content:  .text(message: ""))
    }
}
