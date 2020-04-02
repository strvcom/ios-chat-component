//
//  DataFetching.swift
//  ChatUI
//
//  Created by Daniel Pecher on 02/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

protocol DataFetching {
    typealias ConversationState = ViewModelingState<ListState<Conversation>>
    typealias MessagesState = ViewModelingState<ListState<MessageKitType>>
    
    func load(stateUpdate: @escaping (ConversationState) -> Void)
    func loadMore(stateUpdate: @escaping (ConversationState) -> Void)
    
    func load(messagesForConversation conversation: Conversation, stateUpdate: @escaping (MessagesState) -> Void)
    func loadMore(messagesForConversation conversation: Conversation, stateUpdate: @escaping (MessagesState) -> Void)
}
