//
//  DefaultChatSpecifying.swift
//  Chat
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol DefaultChatSpecifying: ChatSpecifying where
    Networking.C: ChatUIConvertible, Networking.M: ChatUIConvertible, Networking.U: ChatUIConvertible, Networking.MS: ChatUIConvertible,
    UIModels.CUI == Networking.C.ChatUIModel, UIModels.MUI == Networking.M.ChatUIModel, UIModels.USRUI == Networking.U.ChatUIModel, UIModels.MSUI == Networking.MS.ChatUIModel,
    UIModels.MSUI: Cachable, UIModels.MUI: MessageConvertible, UIModels.MUI: MessageStateReflecting, UIModels.MSUI == UIModels.MUI.MessageSpecification,
    Core: ChatCore<Networking, UIModels> {
    
    init(networkConfig: Networking.Config, uiConfig: Interface.UIService.Config)
}
