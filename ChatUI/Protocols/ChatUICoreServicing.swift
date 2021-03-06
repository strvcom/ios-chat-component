//
//  ChatUICoreServicing.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

/// Extension of `ChatCoreServicing` that specializes model types
public protocol ChatUICoreServicing: ChatCoreServicing where UIModels.UIMessage: ContentfulMessageRepresenting, UIModels.UIMessageSpecification: ChatMessageContent {}

extension ChatCore: ChatUICoreServicing where CoreMessage: ContentfulMessageRepresenting, CoreMessageSpecification: ChatMessageContent {}
