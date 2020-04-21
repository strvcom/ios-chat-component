//
//  UIFont+ChatFonts.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIFont {
    static var buttonTitle: UIFont {
        UIConfig.current.fonts.textButtonLarge
    }
    
    static var conversationsListTitle: UIFont {
        UIConfig.current.fonts.headline5
    }
    
    static var conversationsListSubtitle: UIFont {
        UIConfig.current.fonts.headline6
    }
    
    static var conversationsListSubtitleSecondary: UIFont {
        UIConfig.current.fonts.textButtonSmall
    }
    
    static var conversationsListEmptyTitle: UIFont {
        UIConfig.current.fonts.headline2
    }
    
    static var conversationsListEmptySubtitle: UIFont {
        UIConfig.current.fonts.body
    }
    
    static var messageContent: UIFont {
        UIConfig.current.fonts.body
    }
    
    static var messageTopLabel: UIFont {
        UIConfig.current.fonts.smallLabel
    }
    
    static var input: UIFont {
        UIConfig.current.fonts.body
    }
    
    static var inputSendButton: UIFont {
        UIConfig.current.fonts.textButtonSmall
    }
    
    static var navigationTitle: UIFont {
        UIConfig.current.fonts.headline4
    }
}
