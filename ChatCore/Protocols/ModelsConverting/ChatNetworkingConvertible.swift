//
//  ChatNetworkingConvertible.swift
//  ChatCore
//
//  Created by Mireya Orta on 2/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Make UI models conform to this protocol to be able to convert them to the networking models
public protocol ChatNetworkingConvertible {

    associatedtype NetworkingModel
    
    /// This var constructs the networking model from the UI model
    var networkingModel: NetworkingModel { get }
}

public extension ChatNetworkingConvertible where NetworkingModel: ChatUIConvertible, NetworkingModel.ChatUIModel == Self {

    var networkingModel: NetworkingModel {
        return NetworkingModel(uiModel: self)
    }

}

public extension ChatNetworkingConvertible where Self: ChatUIConvertible, NetworkingModel == ChatUIModel {
    var uiModel: Self {
        self
    }
    
    init(uiModel: Self) {
        self = uiModel
    }
}

public protocol ChatUniversalModel: ChatNetworkingConvertible, ChatUIConvertible where ChatUIModel == Self, NetworkingModel == Self {}

public extension ChatUniversalModel {
    var uiModel: Self {
        self
    }
    
    var networkingModel: Self {
        self
    }
    
    init(uiModel: Self) {
        self = uiModel
    }
}
