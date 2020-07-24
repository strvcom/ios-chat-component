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
    let conversation: Conversation
    
    private(set) var state: ViewModelingState<MessagesListState> = .initial {
        didSet {
            delegate?.stateDidChange()
        }
    }

    
    private var listener: ListenerIdentifier?
    
    var currentUser: User {
        core.currentUser
    }
    
    var partner: User? {
        conversation
            .members
            .first { $0.id != currentUser.id }
    }

    init(conversation: Conversation, core: Core) {
        self.conversation = conversation
        self.core = core
    }
    
    deinit {
        guard let listener = listener else {
            return
        }
        
        core.remove(listener: listener)
    }
    
    func load() {
        state = .loading
        
        if let existingListener = listener {
            core.remove(listener: existingListener)
        }
        
        listener = core.listenToMessages(conversation: conversation.id) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let payload):
                self.state = .ready(
                        value: MessagesListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                    )
            case .failure(let error):
                self.state = .failed(error: error)
            }
        }
    }
    
    func loadMore() {
        guard case let .ready(data) = state, !data.reachedEnd else {
            return
        }
        
        state = .loadingMore
        
        core.loadMoreMessages(conversation: conversation.id)
    }
    
    func updateSeenMessage(_ message: Message) {
        core.updateSeenMessage(message.id, in: conversation.id)
    }
    
    func send(message: MessageSpecification, completion: @escaping (Result<Message, ChatError>) -> Void) {
        core.send(message: message, to: conversation.id, completion: completion)
    }
    
    func seen(message: EntityIdentifier) -> Bool {
        conversation.seen.contains { $0.value.messageId == message }
    }
    
    func seenLabel(for message: EntityIdentifier) -> String {
        conversation
            .seen
            .filter { (senderId, data) in
                data.messageId == message && senderId != core.currentUser.id
            }.contains { $0.key != core.currentUser.id } ? "Seen" : ""
    }
}
