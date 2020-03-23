//
//  FontConfig.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

// swiftlint:disable nesting
public class ChatConfig {
    
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
        }
        
        public struct ConversationsList {
            let title: UIColor
            let subtitle: UIColor
            let subtitleSecondary: UIColor
            let separator: UIColor
            let circle: UIColor
            let circleBackground: UIColor
            
            public init(
                title: UIColor,
                subtitle: UIColor,
                subtitleSecondary: UIColor,
                separator: UIColor,
                circle: UIColor,
                circleBackground: UIColor
            ) {
                self.title = title
                self.subtitle = subtitle
                self.subtitleSecondary = subtitleSecondary
                self.separator = separator
                self.circle = circle
                self.circleBackground = circleBackground
            }
        }
        
        let conversationsList: ConversationsList
        
        public init(conversationsList: ConversationsList) {
            self.conversationsList = conversationsList
        }
    }
    
    private static var empty = ChatConfig()
    public static var current: ChatConfig = .empty

    private let fonts: Fonts?
    private let colors: Colors?

    public init(fonts: Fonts, colors: Colors) {
        self.fonts = fonts
        self.colors = colors
    }
    
    private init() {
        fonts = nil
        colors = nil
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
        }
    }
}
