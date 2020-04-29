//
//  ChatUICoreServicing.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ChatUICoreServicing: ChatCoreServicing where CoreConversation == Conversation, CoreMessage == Message, CoreMessageSpecification == MessageSpecification, CoreUser == User { }

extension ChatCore: ChatUICoreServicing where Models.UIConversation == Conversation, Models.UIMessage == Message, Models.UIUser == User { }
