//
//  ChatUICoreServicing.swift
//  ChatUI
//
//  Created by Jan on 25/06/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ChatUICoreServicing: ChatCoreServicing where UIModels.UIMessage: MessageWithContent, UIModels.UIMessageSpecification: MessageSpecificationForContent {}

extension ChatCore: ChatUICoreServicing where CoreMessage: MessageWithContent, CoreMessageSpecification: MessageSpecificationForContent {}
