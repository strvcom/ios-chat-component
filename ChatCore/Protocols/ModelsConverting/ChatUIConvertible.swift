//
//  ChatUIConvertible.swift
//  ChatCore
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Make networking models conform to this protocol to be able to convert them to the UI models
public protocol ChatUIConvertible {

    associatedtype UIModel

    /// This var constructs the UI model from the networking model
    var uiModel: UIModel { get }

    /// Initialize from UI model
    /// - Parameter uiModel: UI Model to initialize from
    init(uiModel: UIModel)
}

public extension ChatUIConvertible where UIModel: ChatNetworkingConvertible, UIModel.NetworkingModel == Self {

    var uiModel: UIModel {
        return UIModel(networkingModel: self)
    }

}
