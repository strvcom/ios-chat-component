//
//  ChatCoreServicingDelegate.swift
//  ChatCore
//
//  Created by Daniel Pecher on 17/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatCoreServicingDelegate: AnyObject {
    func didFailInitialization(withError: ChatError)
}

extension ChatCoreServicingDelegate {
    func didFailInitialization(withError error: ChatError) {
        print(error)
    }
}
