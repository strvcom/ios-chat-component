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
        let messageContent: UIFont
        let messageTopLabel: UIFont
        let input: UIFont
        let inputSendButton: UIFont
        
        public init(
            buttonTitle: UIFont,
            conversationsList: ConversationsList,
            messageContent: UIFont,
            messageTopLabel: UIFont,
            input: UIFont,
            inputSendButton: UIFont
        ) {
            self.buttonTitle = buttonTitle
            self.conversationsList = conversationsList
            self.messageContent = messageContent
            self.messageTopLabel = messageTopLabel
            self.input = input
            self.inputSendButton = inputSendButton
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
            inputText: UIColor
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
        }
    }
    
    // MARK: Strings
    public struct Strings {
        let newConversation: String
        let conversation: String
        let conversationsListEmptyTitle: String
        let conversationsListEmptySubtitle: String
        let conversationsListEmptyActionTitle: String
        let messageInputPlaceholder: String
        
        public init(
            newConversation: String,
            conversation: String,
            conversationsListEmptyTitle: String,
            conversationsListEmptySubtitle: String,
            conversationsListEmptyActionTitle: String,
            messageInputPlaceholder: String
        ) {
            self.newConversation = newConversation
            self.conversation = conversation
            self.conversationsListEmptyTitle = conversationsListEmptyTitle
            self.conversationsListEmptySubtitle = conversationsListEmptySubtitle
            self.conversationsListEmptyActionTitle = conversationsListEmptyActionTitle
            self.messageInputPlaceholder = messageInputPlaceholder
        }
    }
    
    // MARK: Images
    public struct Images {
        let conversationsListEmptyIcon: UIImage
        let inputBarPhotoPickerIcon: UIImage
        
        public init(
            conversationsListEmptyIcon: UIImage,
            inputBarPhotoPickerIcon: UIImage
        ) {
            self.conversationsListEmptyIcon = conversationsListEmptyIcon
            self.inputBarPhotoPickerIcon = inputBarPhotoPickerIcon
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
            ),
            messageContent: .systemFont(ofSize: 12),
            messageTopLabel: .systemFont(ofSize: 12),
            input: .systemFont(ofSize: 12),
            inputSendButton: .systemFont(ofSize: 12)
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
            inputText: .black
        ),
        strings: Strings(
            newConversation: missingString,
            conversation: missingString,
            conversationsListEmptyTitle: missingString,
            conversationsListEmptySubtitle: missingString,
            conversationsListEmptyActionTitle: missingString,
            messageInputPlaceholder: missingString
        ),
        images: Images(
            conversationsListEmptyIcon: UIImage(),
            inputBarPhotoPickerIcon: UIImage()
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
