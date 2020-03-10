//
//  Chat.swift
//  Chat
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatNetworkingFirestore
import ChatUI

public class Chat {
    public typealias Configuration = ChatNetworkingFirestore.Configuration

    let interface: ChatUI<ChatCore<ChatNetworkingFirestore, ChatModelsUI>>
    let core: ChatCore<ChatNetworkingFirestore, ChatModelsUI>

    public init(config: Configuration) {
        let networking = ChatNetworkingFirestore(config: config)
        let core = ChatCore<ChatNetworkingFirestore, ChatModelsUI>(networking: networking)
        self.core = core
        self.interface = ChatUI(core: core)
    }
    
    public func conversationsList() -> UIViewController {
        let list = interface.conversationsList()
    
        return list
    }

    public func resendUnsentMessages() {
        core.resendUnsentMessages()
    }
}
