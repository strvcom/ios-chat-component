//
//  ChatUIConvertible.swift
//  ChatCore
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatUIConvertible {

    associatedtype ChatUIModel

    var uiModel: ChatUIModel { get }

    init(uiModel: ChatUIModel)
}

public protocol ChatNetworkingConvertible {

    associatedtype NetworkingModel

    var networkingModel: NetworkingModel { get }
}


