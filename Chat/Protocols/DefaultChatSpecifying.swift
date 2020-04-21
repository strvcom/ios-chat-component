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
    
    // Specify that associated types
    // Conversation, Message (receive), MessageSpecifying (send) and User
    // of ChatNetworkServicing have to conform to `ChatUIConvertible`
    Networking.C: ChatUIConvertible,
    Networking.M: ChatUIConvertible,
    Networking.MS: ChatUIConvertible,
    
    // Specify that all UI and networking models are inter-convertible
    UIModels.CUI == Networking.C.ChatUIModel,
    UIModels.MUI == Networking.M.ChatUIModel,
    UIModels.MSUI == Networking.MS.ChatUIModel,
    
    // Extra requirements on models for this core implementation
    // supports message caching, message states, temp messages when sending
    UIModels.MSUI: Cachable,
    UIModels.MUI: MessageConvertible,
    UIModels.MUI: MessageStateReflecting,
    UIModels.MSUI == UIModels.MUI.MessageSpecification,
    
    // Use the default implementation of `ChatCore`
    // All the preceeding conditions are just because of this
    Core: ChatCore<Networking, UIModels> {
    
    /// Initialize chat with neworking and ui configurations
    /// - Parameters:
    ///   - networkConfig: Configuration required by underlying `ChatNetworkServicing` implementation
    ///   - uiConfig: Configuration required by underlying `ChatUIServicing` implementation
    init(networkConfig: Networking.Config, uiConfig: Interface.UIService.Config, userManager: Networking.UserManager?)
}
