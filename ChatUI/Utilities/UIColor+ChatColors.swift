//
//  UIColor+ChatColors.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIColor {
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
}
