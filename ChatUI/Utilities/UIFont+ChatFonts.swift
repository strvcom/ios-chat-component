//
//  UIFont+ChatFonts.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIFont {
    static var conversationListTitle: UIFont {
        ChatConfig.current.fontFor(.conversationsTitle)
    }
    
    static var conversationListSubtitle: UIFont {
        ChatConfig.current.fontFor(.conversationsSubtitle)
    }
    
    static var conversationListSubtitleSecondary: UIFont {
        ChatConfig.current.fontFor(.conversationsSubtitleSecondary)
    }
}
