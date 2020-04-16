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

public class MessagesListViewController: MessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    private let dataSource = DataSource()

    var coordinator: RootCoordinating?
    
    private let viewModel: MessagesListViewModeling

    private let photoPickerIconSize = CGSize(width: 44, height: 40)
    
    init(viewModel: MessagesListViewModeling) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.delegate = self

        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        viewModel.send(message: .image(image: image)) { _ in }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        guard indexPath.section == 0 else {
            return
        }

        viewModel.loadMore()
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
        return viewModel.currentUser
    }

    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return self.dataSource.messages[indexPath.section]
    }

    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return self.dataSource.messages.count
    }

    public func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        viewModel.seen(message: message.messageId) ? 20 : 0
    }

    public func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let text = viewModel.seenLabel(for: message.messageId)

        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    public func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        NSAttributedString(string: viewModel.timeLabel(for: message.sentDate), attributes: [
            .font: UIFont.messageTopLabel,
            .foregroundColor: UIColor.messageTopLabel
        ])
    }
    
    public func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        40
    }
    
}

extension MessagesListViewController: MessagesLayoutDelegate {}

// MARK: - MessagesDisplayDelegate
extension MessagesListViewController: MessagesDisplayDelegate {

    public func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .emoji, .photo:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? .outgoingMessageBackground : .incomingMessageBackground
        }
    }

    public func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.isHidden = true
    }

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
        let specs = MessageSpecification.text(message: text)
        
        messageInputBar.inputTextView.text = nil
        messagesCollectionView.scrollToBottom(animated: true)

        viewModel.send(message: specs) { _ in }
    }
}

// MARK: - Setup
private extension MessagesListViewController {
    func setupMessagesLayout() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return
        }
        
        layout.headerReferenceSize = CGSize(width: messagesCollectionView.frame.size.width, height: 50)
        
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.textMessageSizeCalculator.messageLabelFont = .messageContent
        layout.textMessageSizeCalculator.incomingMessageLabelInsets = UIEdgeInsets(top: 10, left: 12, bottom: 6, right: 12)
        layout.textMessageSizeCalculator.outgoingMessageLabelInsets = UIEdgeInsets(top: 10, left: 12, bottom: 6, right: 12)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
    
    func setupInputBar() {
        messageInputBar.delegate = self

        let item = InputBarButtonItem()
            .onTouchUpInside { [weak self] _ in
                self?.displayImagePicker()
            }

        item.setSize(photoPickerIconSize, animated: false)
        
        item.setImage(.inputBarPhotoPickerIcon, for: .normal)

        item.imageView?.contentMode = .scaleAspectFit
        messageInputBar.setLeftStackViewWidthConstant(to: photoPickerIconSize.width, animated: false)
        messageInputBar.setStackViewItems([item], forStack: .left, animated: false)

        messageInputBar.separatorLine.isHidden = true
        
        messageInputBar.contentView.backgroundColor = .inputBackround
        messageInputBar.contentView.layer.cornerRadius = 10
        messageInputBar.middleContentViewPadding = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 8)
        messageInputBar.padding = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)

        messageInputBar.inputTextView.placeholderLabel.text = .messageInputPlaceholder
        messageInputBar.inputTextView.placeholderLabel.font = .input
        messageInputBar.inputTextView.placeholderLabel.textColor = .inputPlaceholder
        messageInputBar.inputTextView.textColor = .inputText
        
        messageInputBar.sendButton.setTitleColor(.inputSendButton, for: .normal)
        messageInputBar.sendButton.setTitleColor(.clear, for: .disabled)
        messageInputBar.sendButton.titleLabel?.font = .inputSendButton
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
    func setup() {
        view.backgroundColor = .chatBackground
        
        if let partner = viewModel.partner {
            navigationItem.titleView = ConversationDetailNavigationTitle(user: partner)
        }

        let moreButtonImage: UIImage = .moreButton
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: moreButtonImage.withRenderingMode(.alwaysOriginal),
            style: .plain,
            target: self,
            action: #selector(didTapMoreButton)
        )

        setupInputBar()
        setupMessagesLayout()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        viewModel.load()
    }

    func markSeenMessage() {
        guard let lastMessage = self.dataSource.messages.last else {
            return
        }
        viewModel.updateSeenMessage(lastMessage)
    }
}

// MARK: MessagesListViewModelDelegate
extension MessagesListViewController: MessagesListViewModelDelegate {
    func didTransitionToState(_ state: ViewModelingState<MessagesListState>) {
        
        switch state {
        case .initial:
            break
        case .ready(let data):
            
            if dataSource.messages.isEmpty {
                messagesCollectionView.scrollToBottom()
            }
            
            dataSource.messages = data.items
            
            let oldOffset = messagesCollectionView.contentSize.height - messagesCollectionView.contentOffset.y
            messagesCollectionView.reloadData()
            messagesCollectionView.layoutIfNeeded()
            messagesCollectionView.contentOffset = CGPoint(x: 0, y: messagesCollectionView.contentSize.height - oldOffset)

            markSeenMessage()
        case .failed(let error):
            print(error)
        case .loading:
            dataSource.messages = []
            messagesCollectionView.reloadData()
        case .loadingMore:
            break
        }
    }
    
    @objc func didTapMoreButton() {
        coordinator?.conversationDetailMoreButtonAction(conversation: viewModel.conversation)
    }
}
