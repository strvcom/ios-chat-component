//
//  Chat.swift
//  Chat
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public protocol ChatSpecifying {
    associatedtype UIModels
    associatedtype Networking
    associatedtype Core where Core.Networking == Networking, Core.UIModels == UIModels
    associatedtype Interface: ChatInterface where Interface.UIService.Core == Core, Interface.UIService.Models == UIModels
    
    func interface(with identifier: ObjectIdentifier) -> Interface
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void)
    func resendUnsentMessages()
    func setCurrentUser(userId: EntityIdentifier, name: String, imageUrl: URL?)
}

public typealias ChatMessageKitFirestore = Chat<MessageKitFirestore>

public class Chat<Implementation: ChatSpecifying> {
    private let implementation: Implementation
    
    init(implementation: Implementation) {
        self.implementation = implementation
    }
    
    public func interface() -> Implementation.Interface {
        return implementation.interface(with: ObjectIdentifier(self))
    }

    public func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        implementation.runBackgroundTasks(completion: completion)
    }

    public func resendUnsentMessages() {
        implementation.resendUnsentMessages()
    }
    
    public func setCurrentUser(userId: EntityIdentifier, name: String, imageUrl: URL?) {
        implementation.setCurrentUser(userId: userId, name: name, imageUrl: imageUrl)
    }
}

// MARK: iOS 13
@available(iOS 13.0, *)
public extension Chat {
    func interface(for scene: UIScene) -> Implementation.Interface {
        return implementation.interface(with: ObjectIdentifier(scene))
    }
}

// MARK: Class methods
public protocol ChatCoreUsing: ChatSpecifying where
    Networking.C: ChatUIConvertible, Networking.M: ChatUIConvertible, Networking.U: ChatUIConvertible, Networking.MS: ChatUIConvertible,
    UIModels.CUI == Networking.C.ChatUIModel, UIModels.MUI == Networking.M.ChatUIModel, UIModels.USRUI == Networking.U.ChatUIModel, UIModels.MSUI == Networking.MS.ChatUIModel,
    UIModels.MSUI: Cachable, UIModels.MUI: MessageConvertible, UIModels.MUI: MessageStateReflecting, UIModels.MSUI == UIModels.MUI.MessageSpecification,
    Core: ChatCore<Networking, UIModels> {
    
    init(networkConfig: Networking.Config, uiConfig: Interface.UIService.Config)
}

extension ChatCoreUsing {
    static func core(networkConfig: Networking.Config) -> ChatCore<Networking, UIModels> {
        let networking = Networking(config: networkConfig)
        let core = ChatCore<Networking, UIModels>(networking: networking)
        return core
    }
    
    static func uiService(core: Interface.UIService.Core, uiConfig: Interface.UIService.Config) -> Interface.UIService {
        let interface = Interface.UIService(core: core, config: uiConfig)
        return interface
    }
}

public extension Chat where Implementation: ChatCoreUsing {
    convenience init(networkConfig: Implementation.Networking.Config, uiConfig: Implementation.Interface.UIService.Config) {
        let implementation = Implementation(networkConfig: networkConfig, uiConfig: uiConfig)
        
        self.init(implementation: implementation)
    }
}
