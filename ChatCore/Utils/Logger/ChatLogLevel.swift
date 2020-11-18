//
//  ChatLogLevel.swift
//  ChatCore
//
//  Created by Jan on 18.11.2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Logging level
///
/// - off: Logging is completely turned off
/// - critical: Show only critical messages e.g. reason of intentional crash
/// - info: Show info about what is going on in the framework
/// - debug: Show info about what is going on in the framework along with I/O data description
public enum ChatLogLevel: Int {
    case off
    case critical
    case info
    case debug
}
