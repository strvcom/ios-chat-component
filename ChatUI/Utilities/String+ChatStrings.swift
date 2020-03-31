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
        UIConfig.current.strings.newConversation
    }
    
    static var conversation: String {
        UIConfig.current.strings.conversation
    }
    
    static var emptyConversationsTitle: String {
        UIConfig.current.strings.emptyConversationsTitle
    }
    
    static var emptyConversationsSubtitle: String {
        UIConfig.current.strings.emptyConversationsSubtitle
    }
    
    static var emptyConversationsActionTitle: String {
        UIConfig.current.strings.emptyConversationsActionTitle
    }
}
