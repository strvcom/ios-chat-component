//
//  ChatModel.swift
//  ChatCore
//
//  Created by Jan on 29/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatModel: ChatNetworkingConvertible, ChatUIConvertible where ChatUIModel == Self, NetworkingModel == Self {}

public extension ChatModel {
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
