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

public class MessagesViewController<ViewModel: MessagesListViewModeling>: MessageKit.MessagesViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MessagesList {
    
    private var messages: [ViewModel.Message] = []

    public weak var actionsDelegate: MessagesListActionsDelegate?
    
    private let viewModel: ViewModel

    // MARK: Constants
    private let photoPickerIconSize = CGSize(width: 44, height: 40)
    private let messageInsets = UIEdgeInsets(top: 10, left: 12, bottom: 6, right: 12)
    private let sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    private let inputBarPadding = UIEdgeInsets(top: 8, left: 24, bottom: 8, right: 24)
    private let inputBarContentPadding = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 8)
    private let inputBarCornerRadius: CGFloat = 10
    
    var state: ViewControllerState?
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: self.traitCollection.userInterfaceStyle == .dark ? .white : .gray)
        indicator.startAnimating()
        return indicator
    }()

    private lazy var emptyStateView: EmptyMessagesList = {
        let view = EmptyMessagesList.nibInstance
        
        view.configure(
            with: EmptyMessagesListViewModel(
                title: .conversationDetailEmptyTitle(name: viewModel.partner?.name ?? ""),
                subtitle: .conversationDetailEmptySubtitle
            )
        )
        
        return view
    }()

    init(viewModel: ViewModel) {
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
        
        let kind: MessageKind = .photo(Media(url: nil, image: image))
        if let message = ViewModel.MessageSpecification.specification(for: kind) {
            viewModel.send(message: message) { _ in }
        }
    }
    
    override public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        super.collectionView(collectionView, willDisplay: cell, forItemAt: indexPath)
        
        guard indexPath.section == 0 else {
            return
        }

        viewModel.loadMore()
    }
    
    // MARK: - Actions
    @objc func didTapMoreButton() {
        actionsDelegate?.didTapOnMoreButton?(for: viewModel.conversationId, in: self)
    }
}

// MARK: - MessagesDataSource
extension MessagesViewController: MessagesDataSource {
    public func currentSender() -> SenderType {
        return viewModel.currentUser.sender
    }

    public func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section].messageType
    }

    public func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }

    public func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        viewModel.seen(message: message.messageId) ? 20 : 0
    }

    public func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let text = viewModel.seenLabel(for: message.messageId)

        return NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }

    public func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        20
    }
}

// MARK: MessagesLayoutDelegate
extension MessagesViewController: MessagesLayoutDelegate {}

// MARK: - MessagesDisplayDelegate
extension MessagesViewController: MessagesDisplayDelegate {

    public func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        switch message.kind {
        case .emoji, .photo:
            return .clear
        default:
            return isFromCurrentSender(message: message) ? .outgoingMessageBackground : .incomingMessageBackground
        }
    }

    public func configureAvatarView(_ avatarView: MessageKit.AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
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
extension MessagesViewController: InputBarAccessoryViewDelegate {

    public func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard let specs = ViewModel.MessageSpecification.specification(for: .text(text)) else {
            return
        }
        
        messageInputBar.inputTextView.text = nil
        messagesCollectionView.scrollToBottom(animated: true)

        viewModel.send(message: specs) { _ in }
    }
}

// MARK: - Setup
private extension MessagesViewController {
    func setup() {
        view.backgroundColor = .chatBackground

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
    
    func setupMessagesLayout() {
        guard let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout else {
            return
        }
        
        layout.headerReferenceSize = CGSize(width: messagesCollectionView.frame.size.width, height: 50)
        
        layout.setMessageIncomingAvatarSize(.zero)
        layout.setMessageOutgoingAvatarSize(.zero)
        layout.textMessageSizeCalculator.messageLabelFont = .messageContent
        layout.textMessageSizeCalculator.incomingMessageLabelInsets = messageInsets
        layout.textMessageSizeCalculator.outgoingMessageLabelInsets = messageInsets
        layout.sectionInset = sectionInset
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
        messageInputBar.contentView.layer.cornerRadius = inputBarCornerRadius
        messageInputBar.middleContentViewPadding = inputBarContentPadding
        messageInputBar.padding = inputBarPadding

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
    
    func configureView() {
        navigationItem.title = viewModel.partner?.name
    }
}

// MARK: StatefulViewController
extension MessagesViewController: StatefulViewController {
    var contentView: UIView? {
        switch state {
        case .empty:
            return emptyStateView
        case .loading:
            return loadingIndicator
        case .loaded:
            return messagesCollectionView
        case let .error(error):
            return ErrorView(message: error?.localizedDescription ?? "Unknown error")
        case .none:
            return nil
        }
    }
}

// MARK: - Private methods
private extension MessagesViewController {
    func markSeenMessage() {
        guard let lastMessage = messages.last else {
            return
        }
        viewModel.updateSeenMessage(lastMessage)
    }
}

// MARK: MessagesListViewModelDelegate
extension MessagesViewController: MessagesListViewModelDelegate {
    public func stateDidChange() {
        switch viewModel.state {
        case .initial:
            break
        case .ready(let data):
            configureView()
            
            // Scroll to the bottom on first load
            if messages.isEmpty {
                messagesCollectionView.scrollToBottom()
            }
            
            messages = data.items
            
            let oldOffset = messagesCollectionView.contentSize.height - messagesCollectionView.contentOffset.y
            messagesCollectionView.reloadData()
            messagesCollectionView.layoutIfNeeded()
            messagesCollectionView.contentOffset = CGPoint(x: 0, y: messagesCollectionView.contentSize.height - oldOffset)

            markSeenMessage()
            
            let newState: ViewControllerState = messages.isEmpty ? .empty : .loaded
            setState(newState)
        case .failed(let error):
            setState(.error(error: error))
        case .loading:
            messages = []
            setState(.loading)
            messagesCollectionView.reloadData()
        case .loadingMore:
            break
        }
    }
}
