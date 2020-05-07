//
//  ChatModel.swift
//  ChatCore
//
//  Created by Jan on 29/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Chat model that is used for both, UI and networking services
///
/// Such model by definition conforms to `ChatNetworkingConvertible` and `ChatUIConvertible` and the conversion is implicit because networking representation of such UI model is the same model and vice-versa.
public protocol ChatModel: ChatNetworkingConvertible, ChatUIConvertible where UIModel == Self, NetworkingModel == Self {}

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
    
    init(networkingModel: Self) {
        self = networkingModel
    }
}
