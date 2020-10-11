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
    
    /// Initialize from networking model
    /// - Parameter uiModel: Networking model to initialize from
    init(networkingModel: NetworkingModel)
}

public extension ChatNetworkingConvertible where NetworkingModel: ChatUIConvertible, NetworkingModel.UIModel == Self {

    var networkingModel: NetworkingModel {
        return NetworkingModel(uiModel: self)
    }

}
