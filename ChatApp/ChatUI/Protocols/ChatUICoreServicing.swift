//
//  ChatUICoreServicing.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ChatUICoreServicing: ChatCoreServicing where C == Conversation, M == MessageKitType,
                MS == MessageSpecification, U == User { }

extension ChatCore: ChatUICoreServicing where Models.CUI == Conversation, Models.MSUI == MessageSpecification,
          Models.MUI == MessageKitType, Models.USRUI == User { }
