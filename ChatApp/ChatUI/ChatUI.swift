//
//  ChatUI.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public class ChatUI<Core: ChatUICoreServicing>: ChatUIServicing {
    public typealias C = Conversation
    public typealias M = MessageKitType
    public typealias MS = MessageSpecification

    let core: Core
    
    required public init(core: Core) {
        self.core = core
    }
    
    public func conversationsList() -> UIViewController {
        let list = ConversationsListViewController(core: core)
        let navigation = UINavigationController(rootViewController: list)
        return navigation
    }
}
