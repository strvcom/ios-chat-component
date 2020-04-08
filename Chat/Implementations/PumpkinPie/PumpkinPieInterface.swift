//
//  PumpkinPieInterface.swift
//  Chat
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatUI

public class PumpkinPieInterface: ChatInterfacing {
    public let identifier: ObjectIdentifier
    public let uiService: ChatUI<PumpkinPieChat.Core>
    
    public var delegate: ChatUIDelegate? {
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
        
    init(identifier: ObjectIdentifier, core: PumpkinPieChat.Core, config: UIService.Config) {
        self.identifier = identifier
        self.uiService = PumpkinPieChat.uiService(core: core, uiConfig: config)
    }
}
