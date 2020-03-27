//
//  UIFont+ChatFonts.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIFont {
    static var conversationsListTitle: UIFont {
        UIConfig.current.fonts.conversationsList.title
    }
    
    static var conversationsListSubtitle: UIFont {
        UIConfig.current.fonts.conversationsList.subtitle
    }
    
    static var conversationsListSubtitleSecondary: UIFont {
        UIConfig.current.fonts.conversationsList.subtitleSecondary
    }
}
