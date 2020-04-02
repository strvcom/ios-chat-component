//
//  DataFetcher.swift
//  ChatUI
//
//  Created by Daniel Pecher on 02/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

class DataFetcher<Core: ChatUICoreServicing>: DataFetching {
    
    private let core: Core
    private var listener: ListenerIdentifier?
    
    private var conversationsState: ViewModelingState<ListState<Conversation>> = .initial
    private var messagesState: ViewModelingState<ListState<MessageKitType>> = .initial
    
    init(core: Core) {
        self.core = core
    }

    deinit {
        guard let listener = listener else {
            return
        }
        
        core.remove(listener: listener)
    }

    // MARK: Conversations
    func load(stateUpdate: @escaping (DataFetching.ConversationState) -> Void) {
        stateUpdate(.loading)

        listener = core.listenToConversations { result in
            switch result {
            case .success(let payload):
                stateUpdate(
                    .ready(
                        value: ListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                    )
                )
            case .failure(let error):
                stateUpdate(.failed(error: error))
            }
        }
    }
    
    func loadMore(stateUpdate: @escaping (ConversationState) -> Void) {
        guard case let .ready(data) = conversationsState, !data.reachedEnd else {
            return
        }
        
        stateUpdate(.loadingMore)

        core.loadMoreConversations()
    }
    
    
    // MARK: Messages
    func load(messagesForConversation conversation: Conversation, stateUpdate: @escaping (DataFetching.MessagesState) -> Void) {
        stateUpdate(.loading)
        
        listener = core.listenToMessages(conversation: conversation.id) { result in
            switch result {
            case .success(let payload):
                stateUpdate(
                    .ready(
                        value: ListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                    )
                )
            case .failure(let error):
                stateUpdate(.failed(error: error))
            }
        }
    }
    
    func loadMore(messagesForConversation conversation: Conversation, stateUpdate: @escaping (MessagesState) -> Void) {
        guard case let .ready(data) = messagesState, !data.reachedEnd else {
            return
        }
        
        stateUpdate(.loadingMore)

        core.loadMoreMessages(conversation: conversation.id)
    }
}
