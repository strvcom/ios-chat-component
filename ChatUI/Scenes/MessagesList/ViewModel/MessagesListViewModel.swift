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
    
    weak var delegate: MessagesListViewModelDelegate?
    
    private let core: Core
    private let dataFetcher: DataFetching
    private let conversation: Conversation

    init(conversation: Conversation, core: Core, dataFetcher: DataFetching) {
        self.conversation = conversation
        self.core = core
        self.dataFetcher = dataFetcher
    }
    
    func load() {
        dataFetcher.load(messagesForConversation: conversation) { [weak self] in self?.updateState(state: $0) }
    }
    
    func loadMore() {
        dataFetcher.loadMore(messagesForConversation: conversation) { [weak self]  in self?.updateState(state: $0) }
    }
    
    func updateSeenMessage(_ message: MessageKitType) {
        core.updateSeenMessage(message, in: conversation.id)
    }
    
    func send(message: MessageSpecification, completion: @escaping (Result<MessageKitType, ChatError>) -> Void) {
        core.send(message: message, to: conversation.id, completion: completion)
    }
    
    func messageBottomLabelHeight(for message: MessageType) -> CGFloat {
        conversation.seen.contains { $0.value.messageId == message.messageId } ? 20 : 0
    }
    
    func messageBottomLabelText(for message: MessageType) -> String {
        guard let sender = core.currentUser else {
            return ""
        }
        
        let seenMessages: [String: (messageId: ObjectIdentifier, seenAt: Date)] = conversation.seen.filter { $0.value.messageId == message.messageId && $0.key != sender.senderId }

        if conversation.members.count == 2 && seenMessages.contains(where: { $0.key != sender.senderId }) {
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
    func updateState(state: DataFetching.MessagesState) {
        delegate?.didTransitionToState(state)
    }
}
