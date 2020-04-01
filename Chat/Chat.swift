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
    public typealias NetworkConfiguration = ChatNetworkingFirestoreConfig
    public typealias UIConfiguration = Interface.Config
    public typealias UIDelegate = ChatUIDelegate
    
    public typealias Core = ChatCore<ChatNetworkingFirestore, ChatModelsUI>
    public typealias Interface = ChatUI<Core>
    
    public var uiDelegate: UIDelegate? {
        get {
            interface.delegate
        }
        set {
            interface.delegate = newValue
        }
    }

    let core: Core
    let interface: Interface

    public init(networkConfig: NetworkConfiguration, uiConfig: UIConfiguration) {
        let networking = ChatNetworkingFirestore(config: networkConfig)
        
        self.core = Core(networking: networking)
        
        self.interface = Interface(
            core: core,
            config: uiConfig
        )
    }
}

// MARK: - UI
public extension Chat {
    func conversationsList() -> UIViewController {
        interface.rootViewController
    }
}

// MARK: - Messages
public extension Chat {
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        core.runBackgroundTasks(completion: completion)
    }

    func resendUnsentMessages() {
        core.resendUnsentMessages()
    }
}

// MARK: - Users
public extension Chat {
    func setCurrentUser(userId: ObjectIdentifier, name: String, imageUrl: URL?) {
        let user = User(id: userId, name: name, imageUrl: imageUrl, compatibility: nil)
        core.setCurrentUser(user: user)
    }
}
