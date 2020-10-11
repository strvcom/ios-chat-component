//
//  ChatMessageContent.swift
//  ChatUI
//
//  Created by Jan on 11/10/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ChatMessageContent: MessageKindSpecifying, MessageSpecifying {
    static func specification(for messageKitKind: ChatMessageKind) -> Self?
}
