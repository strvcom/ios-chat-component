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
    static func core(networkConfig: Networking.Config) -> ChatCore<Networking, UIModels> {
        let networking = Networking(config: networkConfig)
        let core = ChatCore<Networking, UIModels>(networking: networking)
        return core
    }
    
    static func uiService(core: Interface.UIService.Core, uiConfig: Interface.UIService.Config) -> Interface.UIService {
        let interface = Interface.UIService(core: core, config: uiConfig)
        return interface
    }
}
