//
//  Chat+ConvenienceInit.swift
//  Chat
//
//  Created by Jan on 31/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import ChatNetworkingFirestore
import ChatUI

public extension Chat {
    convenience init(networkConfig: ChatMessageKitFirestore.NetworkConfiguration, uiConfig: ChatMessageKitFirestore.UIConfiguration) {
        self.init()
        
        self.implementation = ChatMessageKitFirestore(networkConfig: networkConfig, uiConfig: uiConfig)
    }
}
