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
    
    typealias Core = ChatCore<ChatNetworkingFirestore, ChatModelsUI>
    // swiftlint:disable:next type_name
    typealias UI = ChatUI<Core, ChatConfig>

    let core: Core
    let interface: UI

    public init(networkConfig: Configuration, chatConfig: UIConfig) {
        let networking = ChatNetworkingFirestore(config: networkConfig)
        
        self.core = Core(networking: networking)
        
        self.interface = UI(
            core: core,
            config: chatConfig
        )
    }
    
    public func conversationsList() -> UIViewController {
        interface.rootViewController
    }

    public func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        core.runBackgroundTasks(completion: completion)
    }

    public func resendUnsentMessages() {
        core.resendUnsentMessages()
    }
}
