//
//  MessageContentText.swift
//  ChatApp
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import ChatUI

enum MessageContentText: ChatUIMessageContent, Equatable {
    case simple(String)
    case attributed(NSAttributedString)
    
    var kind: ChatUIMessageKitKind {
        switch self {
        case let .simple(text):
            return .text(text)
        case let .attributed(attributed):
            return .attributedText(attributed)
        }
    }
}
