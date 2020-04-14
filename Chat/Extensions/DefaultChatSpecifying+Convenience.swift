//
//  DefaultChatSpecifying+Convenience.swift
//  Chat
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

extension DefaultChatSpecifying {
    /// Get instance of default `ChatCore` that uses a given implementation of `ChatNetworkServicing`
    /// - Parameters:
    ///     - networkConfig: Configuration required by underlying `ChatNetworkServicing` implementation
    ///     - userManager: Service providing data about users
    /// - Returns: Instance of default `ChatCore`
    static func core(networkConfig: Networking.Config, userManager: Networking.UserManager) -> ChatCore<Networking, UIModels> {
        let networking = Networking(config: networkConfig, userManager: userManager)
        let core = ChatCore<Networking, UIModels>(networking: networking)
        return core
    }
    
    /// Get instance of a given `ChatUIServicing` that uses the specified instance of `ChatCoreServicing`
    /// - Parameters:
    ///   - core: Instance of `ChatCoreServicing` that should be used by the UI
    ///   - uiConfig: Configuration required by underlying `ChatUIServicing` implementation
    /// - Returns: Instance of a given `ChatUIServicing`
    static func uiService(core: Interface.UIService.Core, uiConfig: Interface.UIService.Config) -> Interface.UIService {
        let interface = Interface.UIService(core: core, config: uiConfig)
        return interface
    }
}
