//
//  MessagesListViewModeling.swift
//  ChatUI
//
//  Created by Daniel Pecher on 02/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public protocol MessagesListViewModeling: AnyObject {
    associatedtype Core: ChatUICoreServicing
    typealias Message = Core.UIModels.UIMessage
    typealias MessageSpecification = Core.UIModels.UIMessageSpecification
    typealias MessagesListState = ListState<Message>

    var delegate: MessagesListViewModelDelegate? { get set }
    var state: ViewModelingState<MessagesListState> { get }
    var currentUser: Core.UIModels.UIUser { get }
    var partner: Core.UIModels.UIUser? { get }
    var conversationId: EntityIdentifier { get }

    func load()
    func loadMore()
    func updateSeenMessage(_ message: Core.UIModels.UIMessage)
    func send(message: Core.UIModels.UIMessageSpecification, completion: @escaping (Result<Core.UIModels.UIMessage, ChatError>) -> Void)
    func seen(message: EntityIdentifier) -> Bool
    func seenLabel(for: EntityIdentifier) -> String
}
