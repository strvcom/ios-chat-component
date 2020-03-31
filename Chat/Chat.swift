//
//  Chat.swift
//  Chat
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public class Chat {
    private let defaultInterfaceId = UUID().uuidString
    private var idForScene: [AnyHashable: String] = [:]
    // swiftlint:disable:next implicitly_unwrapped_optional
    var implementation: ChatType!
    
    public func interface() -> UIViewController {
        return interface(with: defaultInterfaceId)
    }

    public func interface(with identifier: String) -> UIViewController {
        guard let chat = implementation else {
            fatalError("Chat hasn't been configured")
        }
        
        return chat.interface(with: identifier)
    }

    public func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let chat = implementation else {
            fatalError("Chat hasn't been configured")
        }
        
        chat.runBackgroundTasks(completion: completion)
    }

    public func resendUnsentMessages() {
        guard let chat = implementation else {
            fatalError("Chat hasn't been configured")
        }
        
        chat.resendUnsentMessages()
    }
}

// MARK: iOS 13
@available(iOS 13.0, *)
public extension Chat {
    
    func interface(for scene: UIScene) -> UIViewController {
        let identifier: String
        
        if let existing = idForScene[scene] {
            identifier = existing
        } else {
            identifier = UUID().uuidString
            idForScene[scene] = identifier
        }
        
        return interface(with: identifier)
    }
    
}

// MARK: Class methods
public extension Chat {
    
    class func interface<UI: ChatUIServicing>(core: UI.Core, uiConfig: UI.Config) -> UI {
        let interface = UI(core: core, config: uiConfig)
        return interface
    }
    
    class func core<Networking, Models: ChatUIModels>(networkConfig: Networking.Config, models: Models.Type) -> ChatCore<Networking, Models> where Networking.C: ChatUIConvertible, Networking.M: ChatUIConvertible, Networking.U: ChatUIConvertible, Networking.MS: ChatUIConvertible, Models.CUI == Networking.C.ChatUIModel, Models.MUI == Networking.M.ChatUIModel, Models.USRUI == Networking.U.ChatUIModel, Models.MSUI: Cachable, Models.MSUI == Networking.MS.ChatUIModel, Models.MUI: MessageConvertible, Models.MUI: MessageStateReflecting {
        
        let networking = Networking(config: networkConfig)
        let core = ChatCore<Networking, Models>(networking: networking)
        return core
    }

}
