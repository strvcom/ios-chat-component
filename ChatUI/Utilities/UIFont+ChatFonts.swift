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
        UIConfig.current.fonts.conversationsList.title
    }
    
    static var conversationListSubtitle: UIFont {
        UIConfig.current.fonts.conversationsList.subtitle
    }
    
    static var conversationListSubtitleSecondary: UIFont {
        UIConfig.current.fonts.conversationsList.subtitleSecondary
    }
}
