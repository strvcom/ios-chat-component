//
//  String+ChatStrings.swift
//  ChatUI
//
//  Created by Daniel Pecher on 24/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

extension String {
    static var newConversation: String {
        ChatConfig.current.stringFor(.newConversation)
    }
    
    static var conversation: String {
        ChatConfig.current.stringFor(.conversation)
    }
}
