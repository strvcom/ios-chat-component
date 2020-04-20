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
        
        let headline1: UIFont
        let headline2: UIFont
        let headline3: UIFont
        let headline4: UIFont
        let headline5: UIFont
        let headline6: UIFont
        let body: UIFont
        let textButtonLarge: UIFont
        let textButtonSmall: UIFont
        let label: UIFont
        let smallLabel: UIFont
        let textField: UIFont
        
        public init(
            headline1: UIFont,
            headline2: UIFont,
            headline3: UIFont,
            headline4: UIFont,
            headline5: UIFont,
            headline6: UIFont,
            body: UIFont,
            textButtonLarge: UIFont,
            textButtonSmall: UIFont,
            label: UIFont,
            smallLabel: UIFont,
            textField: UIFont
        ) {
            self.headline1 = headline1
            self.headline2 = headline2
            self.headline3 = headline3
            self.headline4 = headline4
            self.headline5 = headline5
            self.headline6 = headline6
            self.body = body
            self.textButtonLarge = textButtonLarge
            self.textButtonSmall = textButtonSmall
            self.label = label
            self.smallLabel = smallLabel
            self.textField = textField
        }
    }
    
    // MARK: Colors
    public struct Colors {
        
        let background: UIColor
        let text: UIColor
        let lightText: UIColor
        let primary: UIColor
        let buttonForeground: UIColor
        let outgoingMessageBackground: UIColor
        let incomingMessageBackground: UIColor
        let outgoingMessageForeground: UIColor
        let incomingMessageForeground: UIColor
        let messageTopLabel: UIColor
        let inputBackground: UIColor
        let inputPlaceholder: UIColor
        let inputText: UIColor
        let navigationBarTint: UIColor
        let navigationTitle: UIColor
        
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
            buttonForeground: UIColor,
            outgoingMessageBackground: UIColor,
            incomingMessageBackground: UIColor,
            outgoingMessageForeground: UIColor,
            incomingMessageForeground: UIColor,
            messageTopLabel: UIColor,
            inputBackground: UIColor,
            inputPlaceholder: UIColor,
            inputText: UIColor,
            navigationBarTint: UIColor,
            navigationTitle: UIColor
        ) {
            self.background = background
            self.text = text
            self.lightText = lightText
            self.primary = primary
            self.conversationsList = conversationsList
            self.loadingIndicator = loadingIndicator
            self.buttonForeground = buttonForeground
            self.outgoingMessageBackground = outgoingMessageBackground
            self.incomingMessageBackground = incomingMessageBackground
            self.outgoingMessageForeground = outgoingMessageForeground
            self.incomingMessageForeground = incomingMessageForeground
            self.messageTopLabel = messageTopLabel
            self.inputBackground = inputBackground
            self.inputPlaceholder = inputPlaceholder
            self.inputText = inputText
            self.navigationBarTint = navigationBarTint
            self.navigationTitle = navigationTitle
        }
    }
    
    // MARK: Strings
    public struct Strings {
        let newConversation: String
        let conversation: String
        let conversationsListEmptyTitle: String
        let conversationsListEmptySubtitle: String
        let conversationsListEmptyActionTitle: String
        let conversationsListNavigationTitle: String
        let messageInputPlaceholder: String

        public init(
            newConversation: String,
            conversation: String,
            conversationsListEmptyTitle: String,
            conversationsListEmptySubtitle: String,
            conversationsListEmptyActionTitle: String,
            conversationsListNavigationTitle: String,
            messageInputPlaceholder: String
        ) {
            self.newConversation = newConversation
            self.conversation = conversation
            self.conversationsListEmptyTitle = conversationsListEmptyTitle
            self.conversationsListEmptySubtitle = conversationsListEmptySubtitle
            self.conversationsListEmptyActionTitle = conversationsListEmptyActionTitle
            self.conversationsListNavigationTitle = conversationsListNavigationTitle
            self.messageInputPlaceholder = messageInputPlaceholder
        }
    }
    
    // MARK: Images
    public struct Images {
        let conversationsListEmptyIcon: UIImage
        let inputBarPhotoPickerIcon: UIImage
        let backButton: UIImage
        let moreButton: UIImage
        
        public init(
            conversationsListEmptyIcon: UIImage,
            inputBarPhotoPickerIcon: UIImage,
            backButton: UIImage,
            moreButton: UIImage
        ) {
            self.conversationsListEmptyIcon = conversationsListEmptyIcon
            self.inputBarPhotoPickerIcon = inputBarPhotoPickerIcon
            self.backButton = backButton
            self.moreButton = moreButton
        }
    }
    
    private static let missingString = "(Missing string)"
    
    private static var `default` = UIConfig(
        fonts: Fonts(
            headline1: .systemFont(ofSize: 32),
            headline2: .systemFont(ofSize: 24),
            headline3: .systemFont(ofSize: 20),
            headline4: .systemFont(ofSize: 18),
            headline5: .systemFont(ofSize: 16),
            headline6: .systemFont(ofSize: 14),
            body: .systemFont(ofSize: 12),
            textButtonLarge: .systemFont(ofSize: 16),
            textButtonSmall: .systemFont(ofSize: 14),
            label: .systemFont(ofSize: 14),
            smallLabel: .systemFont(ofSize: 12),
            textField: .systemFont(ofSize: 14)
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
            buttonForeground: .white,
            outgoingMessageBackground: .green,
            incomingMessageBackground: .gray,
            outgoingMessageForeground: .white,
            incomingMessageForeground: .black,
            messageTopLabel: .black,
            inputBackground: .clear,
            inputPlaceholder: .gray,
            inputText: .black,
            navigationBarTint: .white,
            navigationTitle: .black
        ),
        strings: Strings(
            newConversation: missingString,
            conversation: missingString,
            conversationsListEmptyTitle: missingString,
            conversationsListEmptySubtitle: missingString,
            conversationsListEmptyActionTitle: missingString,
            conversationsListNavigationTitle: missingString,
            messageInputPlaceholder: missingString
        ),
        images: Images(
            conversationsListEmptyIcon: UIImage(),
            inputBarPhotoPickerIcon: UIImage(),
            backButton: UIImage(),
            moreButton: UIImage()
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
