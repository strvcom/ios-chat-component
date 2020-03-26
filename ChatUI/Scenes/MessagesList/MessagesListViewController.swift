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

public class MessagesListViewController<Core: ChatUICoreServicing>: MessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let core: Core
    let conversation: Conversation
    private let dataSource = DataSource()

    private var listener: ListenerIdentifier?
    private let sender: SenderType
    
    private var loadMoreButtonVisible = true {
        didSet {
            loadMoreButtonVisible ? showLoadMoreButton() : hideLoadMoreButton()
        }
    }
    
    let photoPickerIconSize: CGFloat = 36

    init(conversation: Conversation, core: Core, sender: SenderType) {
        self.core = core
        self.conversation = conversation
        self.sender = sender

        super.init(nibName: nil, bundle: nil)

        setup()
    }

    @available(*, unavailable)
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

        setupInputBar()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        listener = core.listenToMessages(conversation: conversation.id) { [weak self] result in
            
            switch result {
            case .success(let payload):
                self?.loadMoreButtonVisible = payload.reachedEnd == false
                
                self?.dataSource.messages = payload.data
                self?.markSeenMessage()
                self?.messagesCollectionView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }

    @objc
    func loadMore() {
        core.loadMoreMessages(conversation: conversation.id)
    }

    func markSeenMessage() {
        guard let lastMessage = self.dataSource.messages.last else {
            return
        }
        core.updateSeenMessage(lastMessage, in: conversation.id)
    }

    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        self.core.send(message: .image(image: image), to: self.conversation.id) { _ in }
    }
}

extension MessagesListViewController {
    class DataSource: NSObject {
        var messages: [MessageKitType] = []
    }
}

// MARK: - MessagesDataSource
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

    public func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return conversation.seen.contains { $0.value.messageId == message.messageId } ? 20 : 0
    }

    public func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        var text: String = ""

        let seenMessages: [String: (messageId: ObjectIdentifier, seenAt: Date)] = conversation.seen.filter { $0.value.messageId == message.messageId && $0.key != self.sender.senderId }

        if conversation.members.count == 2 && seenMessages.contains { $0.key != self.sender.senderId } {
            text = "Seen"
        } else if conversation.members.count > 2 && seenMessages.count == conversation.members.count - 1 {
            text = "Seen by All"
        } else if conversation.members.count > 2 && !seenMessages.isEmpty {
            let usersIds = seenMessages.compactMap { $0.key }

            let seenUsers = conversation.members.filter { usersIds.contains($0.id) }.compactMap { $0.name }.joined(separator: ",")
            text = "Seen by \(seenUsers)"
        }

        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
}

extension MessagesListViewController: MessagesLayoutDelegate { }

// MARK: - MessagesDisplayDelegate
extension MessagesListViewController: MessagesDisplayDelegate {
    
    public func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        guard case let .photo(media) = message.kind, let imageUrl = media.url else {
            return
        }
        
        imageView.setImage(with: imageUrl)
    }
}

// MARK: - InputBarAccessoryViewDelegate
extension MessagesListViewController: InputBarAccessoryViewDelegate {

    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        self.messageInputBar.sendButton.isEnabled = false
        self.messageInputBar.sendButton.alpha = 0.3

        let specs = MessageSpecification.text(message: text)
        core.send(message: specs, to: conversation.id) { _ in

            self.messageInputBar.inputTextView.text = nil

            self.messagesCollectionView.scrollToBottom(animated: true)


            self.messageInputBar.sendButton.isEnabled = true
            self.messageInputBar.sendButton.alpha = 1.0
        }
    }
}

// MARK: - Setup
private extension MessagesListViewController {
    func setupInputBar() {
        messageInputBar.delegate = self
        
        let item = InputBarButtonItem()
            .onTouchUpInside { [weak self] _ in
                self?.displayImagePicker()
            }
        
        item.setSize(CGSize(
            width: photoPickerIconSize,
            height: photoPickerIconSize
        ), animated: false)
        if #available(iOS 13.0, *) {
            item.setImage(UIImage(systemName: "photo"), for: .normal)
        }
        item.imageView?.contentMode = .scaleAspectFit
        messageInputBar.setLeftStackViewWidthConstant(to: photoPickerIconSize, animated: false)
        messageInputBar.setStackViewItems([item], forStack: .left, animated: false)
    }
    
    func displayImagePicker() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
    }
}

// MARK: - Private methods
private extension MessagesListViewController {
    func showLoadMoreButton() {
        let item = UIBarButtonItem(title: "Load more", style: .plain, target: self, action: #selector(loadMore))
        navigationItem.setRightBarButton(item, animated: false)
    }
    
    func hideLoadMoreButton() {
        navigationItem.rightBarButtonItems = []
    }
}
