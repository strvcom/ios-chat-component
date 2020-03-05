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

    associatedtype ChatUIModel

    /// This var constructs the UI model from the networking model
    var uiModel: ChatUIModel { get }

    /// Initialize from uiModel
    /// - Parameter uiModel: UI Model to initialize from
    init(uiModel: ChatUIModel)
}
