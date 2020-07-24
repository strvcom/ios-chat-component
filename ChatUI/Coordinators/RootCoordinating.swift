//
//  RootCoordinating.swift
//  ChatUI
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

protocol RootCoordinating: AnyObject {
    associatedtype Core: ChatCoreServicing
    
    func navigate(to conversation: Core.UIModels.UIConversation)
    func emptyStateAction()
    func conversationDetailMoreButtonAction(conversation: Core.UIModels.UIConversation)
}
