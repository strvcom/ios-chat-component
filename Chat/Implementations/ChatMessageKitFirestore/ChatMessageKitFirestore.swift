//
//  ChatMessageKitFirestore.swift
//  Chat
//
//  Created by Jan on 31/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatNetworkingFirestore
import ChatUI

public class ChatMessageKitFirestore: ChatType {
    public typealias NetworkConfiguration = ChatNetworkingFirestore.Configuration
    public typealias UIConfiguration = Interface.Config
    public typealias UIDelegate = ChatUIDelegate

    public typealias Core = ChatCore<ChatNetworkingFirestore, ChatModelsUI>
    public typealias Interface = ChatUI<Core>

    let core: Core
    let uiConfig: UIConfiguration
    private(set) var interfaces: [String: Interface] = [:]
      
    // TODO: Missing implementation
    public weak var uiDelegate: AnyObject?

    public init(networkConfig: NetworkConfiguration, uiConfig: UIConfiguration) {
        self.core = Chat.core(networkConfig: networkConfig, models: ChatModelsUI.self)
        self.uiConfig = uiConfig
    }
    
    public func interface(with id: String) -> UIViewController {
        if let interface = interfaces[id] {
            return interface.rootViewController
        } else {
            let interface: Interface = Chat.interface(core: core, uiConfig: uiConfig)
            interfaces[id] = interface
            return interface.rootViewController
        }
    }

    public func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        core.runBackgroundTasks(completion: completion)
    }

    public func resendUnsentMessages() {
        core.resendUnsentMessages()
    }
}
