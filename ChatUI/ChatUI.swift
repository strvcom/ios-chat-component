//
//  ChatUI.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public class ChatUI<Core: ChatUICoreServicing, Config: ChatConfig>: ChatUIServicing {
    
    let core: Core
    
    private lazy var coordinator = RootCoordinator(core: core)
    
    public lazy var rootViewController = coordinator.start()
    
    public required init(core: Core, config: UIConfig) {
        self.core = core
        UIConfig.current = config
    }
}
