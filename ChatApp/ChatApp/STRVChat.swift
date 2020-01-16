//
//  Chat.swift
//  Chat
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatNetworkFirebase
import ChatUI

public class Chat {
    public typealias Configuration = ChatNetworkFirebase.Configuration

    let interface: ChatUI<ChatCore<FirebaseConverter>>

    public init(config: Configuration) {
        let networking = ChatNetworkFirebase(config: config)
        let converter = FirebaseConverter()
        let core = ChatCore(networking: networking, converter: converter)
        self.interface = ChatUI(core: core)
    }
    
    public func conversationsList() -> UIViewController {
        let list = interface.conversationsList()
        
        return list
    }
}
