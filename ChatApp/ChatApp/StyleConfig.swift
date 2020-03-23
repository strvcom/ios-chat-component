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
    static let fonts = ChatConfig.Fonts(
        conversationsList: .init(
            title: UIFont(name: "Catamaran-Medium", size: 16)!,
            subtitle: UIFont(name: "Catamaran-Regular", size: 14)!,
            subtitleSecondary: UIFont(name: "Catamaran-Bold", size: 14)!
        )
    )
    
    static let colors = ChatConfig.Colors(
        conversationsList: .init(
            title: UIColor(red: 87, green: 61, blue: 57),
            subtitle: UIColor(red: 154, green: 139, blue: 136),
            subtitleSecondary: UIColor(red: 254, green: 129, blue: 46),
            separator: UIColor(red: 87, green: 64, blue: 57, alpha: 0.1),
            circle: UIColor(red: 0, green: 195, blue: 67),
            circleBackground: UIColor(red: 229, green: 227, blue: 226),
            avatarInnerBorder: .white
        ),
        loadingIndicator: .gray
    )
}

