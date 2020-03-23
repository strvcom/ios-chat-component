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
        ChatConfig.current.colorFor(.conversationsTitle)
    }
    
    static var conversationsSubtitle: UIColor {
        ChatConfig.current.colorFor(.conversationsSubtitle)
    }
    
    static var conversationsCellSeparator: UIColor {
        ChatConfig.current.colorFor(.conversationsSeparator)
    }
    
    static var conversationsCircleDefault: UIColor {
        ChatConfig.current.colorFor(.conversationsCircle)
    }
    
    static var conversationsCircleBackground: UIColor {
        ChatConfig.current.colorFor(.conversationsCircleBackground)
    }
    
    static var conversationsSubtitleAlert: UIColor {
        ChatConfig.current.colorFor(.conversationsSubtitleSecondary)
    }
    
    static var conversationsListAvatarInnerBorder: UIColor {
        ChatConfig.current.colorFor(.conversationsListAvatarInnerBorder)
    }
    
    static var loadingIndicator: UIColor {
        ChatConfig.current.colorFor(.loadingIndicator)
    }
}
