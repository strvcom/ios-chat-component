//
//  ChatSpecifying.swift
//  ChatApp
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public protocol ChatSpecifying {
    associatedtype UIModels
    associatedtype Networking
    associatedtype Core where Core.Networking == Networking, Core.UIModels == UIModels
    associatedtype Interface: ChatInterfacing where Interface.UIService.Core == Core, Interface.UIService.Models == UIModels
    
    typealias UIConfiguration = Interface.UIService.Config
    typealias NetworkConfiguration = Networking.Config
    
    func interface(with identifier: ObjectIdentifier) -> Interface
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void)
    func resendUnsentMessages()
    func setCurrentUser(userId: EntityIdentifier, name: String, imageUrl: URL?)
}
