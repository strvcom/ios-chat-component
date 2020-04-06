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
    
    public typealias MessagesListState = ListState<MessageKitType>
    
    weak var delegate: MessagesListViewModelDelegate?
    
    private let core: Core
    private(set) var state: ViewModelingState<MessagesListState> = .initial
    private let conversation: Conversation
    
    private var listener: ListenerIdentifier?
    
    var currentUser: User {
        core.currentUser
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
        updateState(.loading)
        
        listener = core.listenToMessages(conversation: conversation.id) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let payload):
                self.updateState(
                    .ready(
                        value: MessagesListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                    )
                )
            case .failure(let error):
                self.updateState(.failed(error: error))
            }
        }
    }
    
    func loadMore() {
        guard case let .ready(data) = state, !data.reachedEnd else {
            return
        }
        
        updateState(.loadingMore)
        
        core.loadMoreMessages(conversation: conversation.id)
    }
    
    func updateSeenMessage(_ message: MessageKitType) {
        core.updateSeenMessage(message, in: conversation.id)
    }
    
    func send(message: MessageSpecification, completion: @escaping (Result<MessageKitType, ChatError>) -> Void) {
        core.send(message: message, to: conversation.id, completion: completion)
    }
    
    func seen(message id: ObjectIdentifier) -> Bool {
        conversation.seen.contains { $0.value.messageId == id }
    }
    
    func seenLabel(for message: ObjectIdentifier) -> String {
        let seenMessages: [String: (messageId: ObjectIdentifier, seenAt: Date)] = conversation.seen.filter { $0.value.messageId == message && $0.key != core.currentUser.senderId }

        if conversation.members.count == 2 && seenMessages.contains(where: { $0.key != core.currentUser.senderId }) {
            return "Seen"
        } else if conversation.members.count > 2 && seenMessages.count == conversation.members.count - 1 {
            return "Seen by All"
        } else if conversation.members.count > 2 && !seenMessages.isEmpty {
            let usersIds = seenMessages.compactMap { $0.key }

            let seenUsers = conversation.members.filter { usersIds.contains($0.id) }.compactMap { $0.name }.joined(separator: ",")
            return "Seen by \(seenUsers)"
        }
        
        return ""
    }
}

private extension MessagesListViewModel {
    func updateState(_ state: ViewModelingState<MessagesListState>) {
        self.state = state
        delegate?.didTransitionToState(state)
    }
}
