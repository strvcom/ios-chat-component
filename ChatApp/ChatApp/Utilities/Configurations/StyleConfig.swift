//
//  StyleConfig.swift
//  ChatApp
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatUI

// swiftlint:disable force_unwrapping
enum AppStyleConfig {
    
    private enum ColorsPalette {
        static let darkBrown = UIColor(hex: 0x573D39)
        static let brown = UIColor(hex: 0x9A8B88)
        static let lightBrown = UIColor(hex: 0xAB9F94)
        static let lightBrown2 = UIColor(hex: 0xB3A79D)
        static let superLight = UIColor(hex: 0xF6F5F4)
        static let orange = UIColor(hex: 0xFE812E)
        static let red = UIColor(hex: 0xFE2E2E)
        static let green = UIColor(hex: 0x00C03B)
    }

    static let fonts = UIConfig.Fonts(
        headline1: extraBold(ofSize: 32),
        headline2: extraBold(ofSize: 24),
        headline3: extraBold(ofSize: 20),
        headline4: extraBold(ofSize: 16),
        headline5: medium(ofSize: 16),
        headline6: regular(ofSize: 14),
        body: regular(ofSize: 16),
        textButtonLarge: extraBold(ofSize: 16),
        textButtonSmall: bold(ofSize: 16),
        label: bold(ofSize: 14),
        smallLabel: medium(ofSize: 12),
        textField: bold(ofSize: 14)
    )
    
    static let colors = UIConfig.Colors(
        background: .white,
        text: ColorsPalette.darkBrown,
        lightText: ColorsPalette.brown,
        primary: ColorsPalette.orange,
        conversationsList: .init(
            separator: UIColor(red: 87, green: 64, blue: 57, alpha: 0.1),
            circle: UIColor(red: 0, green: 195, blue: 67),
            circleBackground: UIColor(red: 229, green: 227, blue: 226),
            avatarInnerBorder: .white
        ),
        loadingIndicator: .gray,
        buttonForeground: .white,
        outgoingMessageBackground: ColorsPalette.green,
        incomingMessageBackground: ColorsPalette.superLight,
        outgoingMessageForeground: .white,
        incomingMessageForeground: ColorsPalette.darkBrown,
        messageTopLabel: ColorsPalette.brown,
        inputBackground: ColorsPalette.superLight,
        inputPlaceholder: ColorsPalette.lightBrown2,
        inputText: ColorsPalette.darkBrown,
        navigationBarTint: .white,
        navigationTitle: ColorsPalette.darkBrown
    )
    
    static let images = UIConfig.Images(
        conversationsListEmptyIcon: UIImage(named: "connectionsEmpty")!,
        inputBarPhotoPickerIcon: UIImage(named: "photoPicker")!,
        backButton: UIImage(named: "backArrow")!,
        moreButton: UIImage(named: "more")!
    )
}

private extension AppStyleConfig {
    
    static func regular(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "Catamaran-Regular", size: size)!
    }
    
    static func medium(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "Catamaran-Medium", size: size)!
    }
    
    static func bold(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "Catamaran-Bold", size: size)!
    }
    
    static func extraBold(ofSize size: CGFloat) -> UIFont {
        UIFont(name: "Catamaran-ExtraBold", size: size)!
    }
    
}
