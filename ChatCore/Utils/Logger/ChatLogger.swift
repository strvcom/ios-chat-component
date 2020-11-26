//
//  ChatLogger.swift
//  ChatCore
//
//  Created by Jan on 18.11.2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Logger
public class ChatLogger {
    private lazy var module: String = {
        let description = NSStringFromClass(Self.self)
        
        return description.components(separatedBy: ".").first ?? "Chat"
    }()
    
    public var level: ChatLogLevel
    
    public init(level: ChatLogLevel = .critical) {
        self.level = level
    }
    
    public func log(_ message: String, level: ChatLogLevel) {
        if level.rawValue <= self.level.rawValue {
            NSLog("\(module) - \(message)")
        }
    }
}
