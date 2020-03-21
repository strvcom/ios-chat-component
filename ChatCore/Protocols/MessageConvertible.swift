//
//  MessageConvertible.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/21/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Make message representing models conform this to allow create new one from message specifying object
public protocol MessageConvertible {

    associatedtype MessageSpecification: MessageSpecifying

    /// Initialize from message specifying
    /// - Parameter messageSpecification: MessageSpecifying to initialize from
    init(messageSpecification: MessageSpecification)
}
