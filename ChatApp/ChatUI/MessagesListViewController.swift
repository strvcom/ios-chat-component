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
    fileprivate let dataSource = DataSource()

    private var listener: ChatListener?
    private let sender: Sender
    
    let photoPickerIconSize: CGFloat = 36

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

        setupInputBar()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        let loadMoreButton = UIBarButtonItem(title: "Load more", style: .plain, target: self, action: #selector(loadMoreMessages))
        navigationItem.setRightBarButton(loadMoreButton, animated: false)
        
        core.loadMessages(
            conversation: conversation.id,
            completion: { [weak self] result in
                
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let messages):
                    self.dataSource.messages = messages
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                case .failure(let error):
                    print(error)
                }
                
            },
            updatesListener: { [weak self] result in
                
                guard let self = self else {
                    return
                }
                
                switch result {
                case .success(let newMessage):
                    
                    // append new message
                    if let lastMessage = self.dataSource.messages.last, lastMessage.messageId == newMessage.messageId {
                        return
                    }

                    self.dataSource.messages.append(newMessage)
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: true)
                case .failure(let error):
                    print(error)
                }
            }
        )
    }
    
    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        self.core.send(message: .image(image: image), to: self.conversation.id) { _ in }
    }

    @objc func loadMoreMessages() {
        core.loadMoreMessages(conversation: conversation.id) { [weak self] result in
            if case let .success(messages) = result {
                self?.dataSource.messages.insert(contentsOf: messages, at: 0)
                self?.messagesCollectionView.reloadData()
            }
        }
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
        core.send(message: specs, to: conversation.id) { result in

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
        item.setImage(UIImage(systemName: "photo"), for: .normal)
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
