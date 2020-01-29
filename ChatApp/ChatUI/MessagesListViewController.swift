//
//  MessagesListViewController.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import MessageKit
import InputBarAccessoryView

public class MessagesListViewController<Core: ChatUICoreServicing>: MessagesViewController {
    let core: Core
    let conversation: Conversation
    fileprivate let dataSource = DataSource()

    private var listener: ChatListener?
    private var sender: Sender

    init(conversation: Conversation, core: Core, sender: Sender) {
        self.core = core
        self.conversation = conversation
        self.sender = sender

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        if let listener = listener {
            core.remove(listener: listener)
        }
    }

    private func setup() {
        view.backgroundColor = .white

        messageInputBar.delegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        listener = core.listenToConversation(with: conversation.id) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.dataSource.messages = messages
                self?.messagesCollectionView.reloadData()
                self?.messagesCollectionView.scrollToBottom(animated: true)
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension MessagesListViewController {
    class DataSource: NSObject {
        var messages: [MessageKitType] = []
    }
}

extension MessagesListViewController: MessagesDataSource {
    public func currentSender() -> SenderType {
        return sender
    }

    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.dataSource.messages[indexPath.section]
    }

    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.dataSource.messages.count
    }
}

extension MessagesListViewController: MessagesLayoutDelegate { }

extension MessagesListViewController: MessagesDisplayDelegate { }

extension MessagesListViewController: InputBarAccessoryViewDelegate {

    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        self.messageInputBar.sendButton.isEnabled = false
        self.messageInputBar.sendButton.alpha = 0.3

        let specs = MessageSpecification.text(message: text)
        core.send(message: specs, to: conversation.id) { result in

            self.messageInputBar.inputTextView.text = nil

            self.messagesCollectionView.scrollToBottom(animated: true)


            self.messageInputBar.sendButton.isEnabled = true
            self.messageInputBar.sendButton.alpha = 1.0
        }
    }
}
