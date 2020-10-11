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
    
    static var conversationsListEmptyTitle: String {
        UIConfig.current.strings.conversationsListEmptyTitle
    }
    
    static var conversationsListEmptySubtitle: String {
        UIConfig.current.strings.conversationsListEmptySubtitle
    }
    
    static var conversationsListEmptyActionTitle: String {
        UIConfig.current.strings.conversationsListEmptyActionTitle
    }
    
    static var conversationsListNavigationTitle: String {
        UIConfig.current.strings.conversationsListNavigationTitle
    }

    static var messageInputPlaceholder: String {
        UIConfig.current.strings.messageInputPlaceholder
    }
    
    static var conversationDetailEmptySubtitle: String {
        UIConfig.current.strings.conversationDetailEmptySubtitle
    }

    static func conversationDetailEmptyTitle(name: String) -> String {
        UIConfig.current.strings.conversationDetailEmptyTitle.replacingOccurrences(of: "%s", with: name)
    }
}
