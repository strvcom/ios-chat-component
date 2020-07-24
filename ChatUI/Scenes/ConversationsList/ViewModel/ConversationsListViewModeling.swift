//
//  ConversationsListViewModeling.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ConversationsListViewModeling: AnyObject {
    associatedtype Core: ChatUICoreServicing
    typealias ConversationsListState = ListState<Core.UIModels.UIConversation>
    typealias Conversation = Core.UIModels.UIConversation

    var delegate: ConversationsListViewModelDelegate? { get set }
    var state: ViewModelingState<ConversationsListState> { get }
    var currentUser: Core.UIModels.UIUser { get }

    func load()
    func loadMore()
}
