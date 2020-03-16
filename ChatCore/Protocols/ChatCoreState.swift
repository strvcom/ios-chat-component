//
//  ChatCoreState.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/12/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - State of chat core
public enum ChatCoreState {
    /// state when chat core created
    case initial
    /// first time connecting to network service and loading itself
    case loading
    /// chat core is ready to be used
    case connected
    /// network service is connecting again
    case connecting
}
