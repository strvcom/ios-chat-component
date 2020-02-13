//
//  ChatNetworkingConvertible.swift
//  ChatCore
//
//  Created by Mireya Orta on 2/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatNetworkingConvertible {

    associatedtype NetworkingModel

    var networkingModel: NetworkingModel { get }
}

extension ChatNetworkingConvertible where NetworkingModel: ChatUIConvertible, NetworkingModel.ChatUIModel == Self {

    public var networkingModel: NetworkingModel {
        return NetworkingModel(uiModel: self)
    }

}