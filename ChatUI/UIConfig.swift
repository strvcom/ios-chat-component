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
        
        public enum Location {
            case conversationsTitle
            case conversationsSubtitle
            case conversationsSubtitleSecondary
        }
        
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
        
        public enum Location {
            case conversationsTitle
            case conversationsSubtitle
            case conversationsSubtitleSecondary
            case conversationsSeparator
            case conversationsCircle
            case conversationsCircleBackground
            case conversationsListAvatarInnerBorder
            
            case loadingIndicator
        }
        
        public struct ConversationsList {
            let title: UIColor
            let subtitle: UIColor
            let subtitleSecondary: UIColor
            let separator: UIColor
            let circle: UIColor
            let circleBackground: UIColor
            let avatarInnerBorder: UIColor
            
            public init(
                title: UIColor,
                subtitle: UIColor,
                subtitleSecondary: UIColor,
                separator: UIColor,
                circle: UIColor,
                circleBackground: UIColor,
                avatarInnerBorder: UIColor
            ) {
                self.title = title
                self.subtitle = subtitle
                self.subtitleSecondary = subtitleSecondary
                self.separator = separator
                self.circle = circle
                self.circleBackground = circleBackground
                self.avatarInnerBorder = avatarInnerBorder
            }
        }
        
        let conversationsList: ConversationsList
        
        let loadingIndicator: UIColor
        
        public init(
            conversationsList: ConversationsList,
            loadingIndicator: UIColor
        ) {
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
    
    private static var empty = UIConfig()
    public static var current: UIConfig = .empty

    private let fonts: Fonts?
    private let colors: Colors?
    private let strings: Strings?

    public init(fonts: Fonts, colors: Colors, strings: Strings) {
        self.fonts = fonts
        self.colors = colors
        self.strings = strings
    }
    
    private init() {
        fonts = nil
        colors = nil
        strings = nil
    }

    // MARK: Getter methods
    func fontFor(_ location: Fonts.Location) -> UIFont {
        guard let fonts = fonts else {
            fatalError("Fonts not configured!")
        }
        
        switch location {
        case .conversationsTitle: return fonts.conversationsList.title
        case .conversationsSubtitle: return fonts.conversationsList.subtitle
        case .conversationsSubtitleSecondary: return fonts.conversationsList.subtitleSecondary
        }
    }
    
    func colorFor(_ location: Colors.Location) -> UIColor {
        guard let colors = colors else {
            fatalError("Colors not configured!")
        }
        
        switch location {
        case .conversationsTitle: return colors.conversationsList.title
        case .conversationsSubtitle: return colors.conversationsList.subtitle
        case .conversationsSubtitleSecondary: return colors.conversationsList.subtitleSecondary
        case .conversationsCircle: return colors.conversationsList.circle
        case .conversationsCircleBackground: return colors.conversationsList.circleBackground
        case .conversationsSeparator: return colors.conversationsList.separator
        case .conversationsListAvatarInnerBorder: return colors.conversationsList.avatarInnerBorder
        case .loadingIndicator: return colors.loadingIndicator
        }
    }
    
    func stringFor(_ identifier: Strings.Identifier) -> String {
        guard let strings = strings else {
            fatalError("Strings not configured!")
        }
        
        switch identifier {
        case .newConversation: return strings.newConversation
        case .conversation: return strings.conversation
        }
    }
}
