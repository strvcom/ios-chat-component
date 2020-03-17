//
//  FontConfig.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public struct FontConfig {
    
    public enum FontLocation {
        case conversationListName
        case conversationPreview
        case newConversationAlert
    }
    
    private let fallbackFont = UIFont.systemFont(ofSize: 14)
    
    var fonts = [FontLocation: UIFont]()
    
    public init(fonts: [FontLocation: UIFont] = [:]) {
        self.fonts = fonts
    }
    
    func fontFor(_ location: FontLocation) -> UIFont {
        fonts[location] ?? fallbackFont
    }
}
