//
//  ChatUIModels.swift
//  ChatCore
//
//  Created by Mireya Orta on 2/6/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// This protocol is used to specify concrete implementations of UI models
public protocol ChatUIModels {
    associatedtype CUI: ConversationRepresenting
    associatedtype MUI: MessageRepresenting & MessageConvertible
    associatedtype MSUI: MessageSpecifying & Cachable
    associatedtype USRUI: UserRepresenting
}
