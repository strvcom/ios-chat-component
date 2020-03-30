//
//  StyleConfig.swift
//  ChatApp
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatUI

enum AppStyleConfig {

    static let fonts = UIConfig.Fonts(
        buttonTitle: extraBold(ofSize: 16),
        conversationsList: .init(
            title: medium(ofSize: 16),
            subtitle: regular(ofSize: 14),
            subtitleSecondary: bold(ofSize: 14),
            emptyTitle: extraBold(ofSize: 20),
            emptySubtitle: regular(ofSize: 16)
        )
    )
    
    static let colors = UIConfig.Colors(
        text: UIColor(red: 87, green: 61, blue: 57),
        lightText: UIColor(red: 154, green: 139, blue: 136),
        primary: UIColor(red: 254, green: 129, blue: 46),
        conversationsList: .init(
            separator: UIColor(red: 87, green: 64, blue: 57, alpha: 0.1),
            circle: UIColor(red: 0, green: 195, blue: 67),
            circleBackground: UIColor(red: 229, green: 227, blue: 226),
            avatarInnerBorder: .white
        ),
        loadingIndicator: .gray,
        buttonForeground: .white
    )
    
    static let images = UIConfig.Images(
        emptyConversationsIcon: UIImage(named: "connectionsEmpty")!
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
