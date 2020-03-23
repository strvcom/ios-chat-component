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
    
    
    
    public func conversationsList() -> UIViewController {
        let list = ConversationsListViewController(core: core)
        let navigation = UINavigationController(rootViewController: list)
        return navigation
    public required init(core: Core, config: ChatConfig) {
        self.core = core
        ChatConfig.current = config
    }
}
