//
//  MessagesListViewModel.swift
//  ChatUI
//
//  Created by Daniel Pecher on 02/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import MessageKit

class MessagesListViewModel<Core: ChatUICoreServicing>: MessagesListViewModeling {
    typealias User = Core.UIModels.UIUser
    typealias Conversation = Core.UIModels.UIConversation
    typealias Message = Core.UIModels.UIMessage
    typealias MessageSpecification = Core.UIModels.UIMessageSpecification
    
    weak var delegate: MessagesListViewModelDelegate?
    
    private let core: Core
    let conversationId: EntityIdentifier
    
    private(set) var state: ViewModelingState<MessagesListState> = .initial {
        didSet {
            delegate?.stateDidChange()
        }
    }
    private var messagesState: ViewModelingState<MessagesListState> = .initial {
        didSet {
            updateState()
        }
    }
    private var conversation: Core.UIModels.UIConversation? {
        didSet {
            updateState()
        }
    }

    private var messagesListener: ListenerIdentifier?
    private var conversationListener: ListenerIdentifier?
        
    var currentUser: User {
        core.currentUser
    }
    
    var partner: User? {
        conversation?
            .members
            .first { $0.id != currentUser.id }
    }
    
    var messages: [Message] {
        guard case let .ready(payload) = state else {
            return []
        }
        
        return payload.items
    }

    init(conversationId: EntityIdentifier, core: Core) {
        self.conversationId = conversationId
        self.core = core
    }
    
    deinit {
        removeListeners()
    }
    
    func load() {
        messagesState = .loading
        
        removeListeners()

        conversationListener = core.listenToConversation(conversation: conversationId, completion: { [weak self] result in
            switch result {
            case .success(let conversation):
                self?.conversation = conversation
            case .failure(let error):
                logger.log("Conversation load failed: \(error)", level: .debug)
                self?.conversation = nil
            }
        })
        messagesListener = core.listenToMessages(conversation: conversationId) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let payload):
                self.messagesState = .ready(
                        value: MessagesListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                    )
            case .failure(let error):
                self.messagesState = .failed(error: error)
            }
        }
    }
    
    func loadMore() {
        guard case let .ready(data) = state, !data.reachedEnd else {
            return
        }
        
        messagesState = .loadingMore
        
        core.loadMoreMessages(conversation: conversationId)
    }
    
    func updateSeenMessage() {
        guard let message = messages.last(where: { $0.userId != self.currentUser.id }) else {
            return
        }
        
        core.updateSeenMessage(message.id, in: conversationId)
    }
    
    func send(message: MessageSpecification, completion: @escaping (Result<Message, ChatError>) -> Void) {
        core.send(message: message, to: conversationId, completion: completion)
    }
    
    func seen(message: EntityIdentifier) -> Bool {
        guard let conversation = conversation else {
            return false
        }
        
        return conversation.seen.contains { $0.value.messageId == message }
    }
    
    func seenLabel(for message: EntityIdentifier) -> String {
        guard let conversation = conversation else {
            return ""
        }
        
        return conversation
            .seen
            .filter { (senderId, data) in
                data.messageId == message && senderId != core.currentUser.id
            }.contains { $0.key != core.currentUser.id } ? "Seen" : ""
    }
}

private extension MessagesListViewModel {
    func removeListeners() {
        if let existingListener = messagesListener {
            core.remove(listener: existingListener)
        }
        if let existingListener = conversationListener {
            core.remove(listener: existingListener)
        }
    }
    
    func updateState() {
        guard conversation != nil else {
            state = .loading
            return
        }
        
        state = messagesState
    }
}
