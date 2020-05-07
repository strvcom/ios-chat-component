//
//  ChatUICoreServicing.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

/// Extension of `ChatCoreServicing` that specializes model types
public protocol ChatUICoreServicing: ChatCoreServicing where CoreConversation == Conversation, CoreMessageSpecification == MessageSpecification { }

extension ChatCore: ChatUICoreServicing where Models.UIConversation == Conversation { }
