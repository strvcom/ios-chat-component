//
//  ChatUIDelegate.swift
//  ChatUI
//
//  Created by Daniel Pecher on 28/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatUIDelegate: AnyObject {
    func conversationsListEmptyListAction()
    func conversationDetailMoreButtonTapped(conversation: Conversation)
}
