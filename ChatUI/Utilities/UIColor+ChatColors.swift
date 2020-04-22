//
//  UIColor+ChatColors.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var chatBackground: UIColor {
        UIConfig.current.colors.background
    }
    
    static var conversationsTitle: UIColor {
        UIConfig.current.colors.text
    }
    
    static var conversationsSubtitle: UIColor {
        UIConfig.current.colors.lightText
    }
    
    static var conversationsCellSeparator: UIColor {
        UIConfig.current.colors.conversationsList.separator
    }
    
    static var conversationsCircleDefault: UIColor {
        UIConfig.current.colors.conversationsList.circle
    }
    
    static var conversationsCircleBackground: UIColor {
        UIConfig.current.colors.conversationsList.circleBackground
    }
    
    static var conversationsSubtitleAlert: UIColor {
        UIConfig.current.colors.primary
    }
    
    static var conversationsListAvatarInnerBorder: UIColor {
        UIConfig.current.colors.conversationsList.avatarInnerBorder
    }
    
    static var loadingIndicator: UIColor {
        UIConfig.current.colors.loadingIndicator
    }
    
    static var conversationsEmptyTitle: UIColor {
        UIConfig.current.colors.text
    }
    
    static var conversationsEmptySubtitle: UIColor {
        UIConfig.current.colors.lightText
    }
    
    static var buttonBackground: UIColor {
        UIConfig.current.colors.primary
    }
    
    static var buttonForeground: UIColor {
        UIConfig.current.colors.buttonForeground
    }
    
    static var incomingMessageBackground: UIColor {
        UIConfig.current.colors.incomingMessageBackground
    }
    
    static var outgoingMessageBackground: UIColor {
        UIConfig.current.colors.outgoingMessageBackground
    }
    
    static var messageTopLabel: UIColor {
        UIConfig.current.colors.messageTopLabel
    }
    
    static var inputBackround: UIColor {
        UIConfig.current.colors.inputBackground
    }
    
    static var inputPlaceholder: UIColor {
        UIConfig.current.colors.inputPlaceholder
    }
    
    static var inputSendButton: UIColor {
        UIConfig.current.colors.primary
    }
    
    static var inputText: UIColor {
        UIConfig.current.colors.inputText
    }
    
    static var navigationBarTintColor: UIColor {
        UIConfig.current.colors.navigationBarTint
    }
    
    static var navigationTitle: UIColor {
        UIConfig.current.colors.navigationTitle
    }
    
    static var conversationDetailEmptyTitle: UIColor {
        UIConfig.current.colors.text
    }
    
    static var conversationDetailEmptySubtitle: UIColor {
        UIConfig.current.colors.lightText
    }
}
