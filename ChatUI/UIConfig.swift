//
//  UIConfig.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

// swiftlint:disable nesting
public class UIConfig {
    
    // MARK: Fonts
    public struct Fonts {
        
        public struct ConversationsList {
            let title: UIFont
            let subtitle: UIFont
            let subtitleSecondary: UIFont
            
            public init(
                title: UIFont,
                subtitle: UIFont,
                subtitleSecondary: UIFont
            ) {
                self.title = title
                self.subtitle = subtitle
                self.subtitleSecondary = subtitleSecondary
            }
        }
        
        let conversationsList: ConversationsList
        
        public init(conversationsList: ConversationsList) {
            self.conversationsList = conversationsList
        }
    }
    
    // MARK: Colors
    public struct Colors {
        
        let text: UIColor
        let lightText: UIColor
        let primary: UIColor
        public struct ConversationsList {
            let separator: UIColor
            let circle: UIColor
            let circleBackground: UIColor
            let avatarInnerBorder: UIColor
            
            public init(
                separator: UIColor,
                circle: UIColor,
                circleBackground: UIColor,
                avatarInnerBorder: UIColor
            ) {
                self.separator = separator
                self.circle = circle
                self.circleBackground = circleBackground
                self.avatarInnerBorder = avatarInnerBorder
            }
        }
        
        let conversationsList: ConversationsList
        
        let loadingIndicator: UIColor
        
        public init(
            text: UIColor,
            lightText: UIColor,
            primary: UIColor,
            conversationsList: ConversationsList,
            loadingIndicator: UIColor
        ) {
            self.text = text
            self.lightText = lightText
            self.primary = primary
            self.conversationsList = conversationsList
            self.loadingIndicator = loadingIndicator
        }
    }
    
    // MARK: Strings
    public struct Strings {
        
        public enum Identifier {
            case newConversation
            case conversation
        }
        
        let newConversation: String
        let conversation: String
        
        public init(
            newConversation: String,
            conversation: String
        ) {
            self.newConversation = newConversation
            self.conversation = conversation
        }
    }
    
    private static let missingString = "(Missing string)"
    
    private static var `default` = UIConfig(
        fonts: Fonts(conversationsList: .init(
            title: .systemFont(ofSize: 14),
            subtitle: .systemFont(ofSize: 12),
            subtitleSecondary: .systemFont(ofSize: 12)
            )
        ),
        colors: Colors(conversationsList: .init(
            title: .black,
            subtitle: .black,
            subtitleSecondary: .black,
            separator: .black,
            circle: .black,
            circleBackground: .black,
            avatarInnerBorder: .black
            ), loadingIndicator: .gray
        ),
        strings: Strings(newConversation: missingString, conversation: missingString)
    )
    
    public static var current: UIConfig = .default

    let fonts: Fonts
    let colors: Colors
    let strings: Strings

    public init(fonts: Fonts, colors: Colors, strings: Strings) {
        self.fonts = fonts
        self.colors = colors
        self.strings = strings
    }
}
