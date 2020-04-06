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

public class MessageKitFirestore: ChatCoreUsing {
    public typealias UIModels = ChatModelsUI
    public typealias Networking = ChatNetworkingFirestore
    public typealias Core = ChatCore<ChatNetworkingFirestore, UIModels>
    public typealias UIService = ChatUI<Core>
    public typealias Interface = MessageKitInterface
    
    public typealias UIConfiguration = UIService.Config
    public typealias NetworkConfiguration = ChatNetworkingFirestoreConfig
    public typealias UIDelegate = ChatUIDelegate

    let core: Core
    let uiConfig: UIService.Config
    private(set) var interfaces: [String: MessageKitInterface] = [:]
      
    public required init(networkConfig: NetworkConfiguration, uiConfig: UIConfiguration) {
        self.core = Self.core(networkConfig: networkConfig)
        self.uiConfig = uiConfig
    }
    
    public func interface(with id: String) -> MessageKitInterface {
        if let interface = interfaces[id] {
            return interface
        } else {
            let interface: Interface = MessageKitInterface(identifier: id, core: core, config: uiConfig)
            interfaces[id] = interface
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
public extension MessageKitFirestore {
    func setCurrentUser(userId: ObjectIdentifier, name: String, imageUrl: URL?) {
        let user = User(id: userId, name: name, imageUrl: imageUrl)
        core.setCurrentUser(user: user)
    }
}

public class MessageKitInterface: ChatInterface {
    public let identifier: String
    public var delegate: MessageKitFirestore.UIDelegate? {
        get {
            uiService.delegate
        }
        set {
            uiService.delegate = newValue
        }
    }
    public var rootViewController: UIViewController {
        uiService.rootViewController
    }
    
    public let uiService: MessageKitFirestore.UIService
    
    init(identifier: String = UUID().uuidString, core: MessageKitFirestore.Core, config: MessageKitFirestore.UIService.Config) {
        self.identifier = identifier
        self.uiService = MessageKitFirestore.uiService(core: core, uiConfig: config)
    }
}
