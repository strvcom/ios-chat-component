//
//  PumpkinPie.swift
//  Chat
//
//  Created by Jan on 31/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatNetworkingFirestore
import ChatUI

public class PumpkinPieChat: DefaultChatSpecifying {
    public typealias UIModels = ChatModelsUI
    public typealias Networking = ChatNetworkingFirestore
    public typealias Core = ChatCore<ChatNetworkingFirestore, UIModels>
    public typealias Interface = PumpkinPieInterface
    
    public typealias UIDelegate = Interface.Delegate

    let core: Core
    let uiConfig: UIConfiguration
    private(set) var interfaces: [ObjectIdentifier: Interface] = [:]
      
    public required init(networkConfig: NetworkConfiguration, uiConfig: UIConfiguration) {
        self.core = Self.core(networkConfig: networkConfig)
        self.uiConfig = uiConfig
    }
    
    public func interface(with identifier: ObjectIdentifier) -> Interface {
        if let interface = interfaces[identifier] {
            return interface
        } else {
            let interface: Interface = Interface(identifier: identifier, core: core, config: uiConfig)
            interfaces[identifier] = interface
            return interface
        }
    }

    public func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        core.runBackgroundTasks(completion: completion)
    }

    public func resendUnsentMessages() {
        core.resendUnsentMessages()
    }
}

// MARK: - Users
public extension PumpkinPieChat {
    func setCurrentUser(userId: EntityIdentifier, name: String, imageUrl: URL?) {
        let user = User(id: userId, name: name, imageUrl: imageUrl)
        core.setCurrentUser(user: user)
    }
}
