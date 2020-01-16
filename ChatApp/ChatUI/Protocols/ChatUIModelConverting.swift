//
//  ChatUIModelConverting.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ChatUIModelConverting: ChatModelConverting where MUI == MessageKitType, CUI == Conversation, MSUI == MessageSpecification {

}
