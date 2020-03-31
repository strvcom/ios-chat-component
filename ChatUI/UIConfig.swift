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
            let emptyTitle: UIFont
            let emptySubtitle: UIFont
            
            public init(
                title: UIFont,
                subtitle: UIFont,
                subtitleSecondary: UIFont,
                emptyTitle: UIFont,
                emptySubtitle: UIFont
            ) {
                self.title = title
                self.subtitle = subtitle
                self.subtitleSecondary = subtitleSecondary
                self.emptyTitle = emptyTitle
                self.emptySubtitle = emptySubtitle
            }
        }
        
        let conversationsList: ConversationsList
        let buttonTitle: UIFont
        
        public init(buttonTitle: UIFont, conversationsList: ConversationsList) {
            self.buttonTitle = buttonTitle
            self.conversationsList = conversationsList
        }
    }
    
    // MARK: Colors
    public struct Colors {
        
        let background: UIColor
        let text: UIColor
        let lightText: UIColor
        let primary: UIColor
        let buttonForeground: UIColor
        
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
            background: UIColor,
            text: UIColor,
            lightText: UIColor,
            primary: UIColor,
            conversationsList: ConversationsList,
            loadingIndicator: UIColor,
            buttonForeground: UIColor
        ) {
            self.background = background
            self.text = text
            self.lightText = lightText
            self.primary = primary
            self.conversationsList = conversationsList
            self.loadingIndicator = loadingIndicator
            self.buttonForeground = buttonForeground
        }
    }
    
    // MARK: Strings
    public struct Strings {
        let newConversation: String
        let conversation: String
        let conversationsListEmptyTitle: String
        let conversationsListEmptySubtitle: String
        let conversationsListEmptyActionTitle: String
        
        public init(
            newConversation: String,
            conversation: String,
            conversationsListEmptyTitle: String,
            conversationsListEmptySubtitle: String,
            conversationsListEmptyActionTitle: String
        ) {
            self.newConversation = newConversation
            self.conversation = conversation
            self.conversationsListEmptyTitle = conversationsListEmptyTitle
            self.conversationsListEmptySubtitle = conversationsListEmptySubtitle
            self.conversationsListEmptyActionTitle = conversationsListEmptyActionTitle
        }
    }
    
    // MARK: Images
    public struct Images {
        let conversationsListEmptyIcon: UIImage
        
        public init(
            conversationsListEmptyIcon: UIImage
        ) {
            self.conversationsListEmptyIcon = conversationsListEmptyIcon
        }
    }
    
    private static let missingString = "(Missing string)"
    
    private static var `default` = UIConfig(
        fonts: Fonts(
            buttonTitle: .systemFont(ofSize: 12),
            conversationsList: .init(
                title: .systemFont(ofSize: 14),
                subtitle: .systemFont(ofSize: 12),
                subtitleSecondary: .systemFont(ofSize: 12),
                emptyTitle: .systemFont(ofSize: 14),
                emptySubtitle: .systemFont(ofSize: 12)
            )
        ),
        colors: Colors(
            background: .white,
            text: .black,
            lightText: .black,
            primary: .black,
            conversationsList: .init(
                separator: .black,
                circle: .black,
                circleBackground: .black,
                avatarInnerBorder: .black
            ),
            loadingIndicator: .gray,
            buttonForeground: .white
        ),
        strings: Strings(
            newConversation: missingString,
            conversation: missingString,
            conversationsListEmptyTitle: missingString,
            conversationsListEmptySubtitle: missingString,
            conversationsListEmptyActionTitle: missingString
        ),
        images: Images(
            conversationsListEmptyIcon: UIImage()
        )
    )
    
    public static var current: UIConfig = .default

    let fonts: Fonts
    let colors: Colors
    let strings: Strings
    let images: Images

    public init(fonts: Fonts, colors: Colors, strings: Strings, images: Images) {
        self.fonts = fonts
        self.colors = colors
        self.strings = strings
        self.images = images
    }
}
