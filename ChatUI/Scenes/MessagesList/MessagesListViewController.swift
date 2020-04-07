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

    private var listener: ListenerIdentifier?
    private let viewModel: MessagesListViewModeling

    private var loadMoreButtonVisible = true {
        didSet {
            loadMoreButtonVisible ? showLoadMoreButton() : hideLoadMoreButton()
        }
    }
    
    let photoPickerIconSize: CGFloat = 36

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

    private func setup() {
        view.backgroundColor = .white

        setupInputBar()

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

        viewModel.load()
    }

    @objc
    func loadMore() {
        viewModel.loadMore()
    }

    func markSeenMessage() {
        guard let lastMessage = self.dataSource.messages.last else {
            return
        }
        viewModel.updateSeenMessage(lastMessage)
    }

    // MARK: - UIImagePickerControllerDelegate
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        
        guard let image = info[.originalImage] as? UIImage else {
            return
        }
        
        picker.dismiss(animated: true)
        
        viewModel.send(message: .image(image: image)) { _ in }
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
        let specs = MessageSpecification.text(message: text)
        
        messageInputBar.inputTextView.text = nil
        messagesCollectionView.scrollToBottom(animated: true)

        viewModel.send(message: specs) { _ in }
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

// MARK: MessagesListViewModelDelegate
extension MessagesListViewController: MessagesListViewModelDelegate {
    func didTransitionToState(_ state: ViewModelingState<MessagesListState>) {
        
        switch state {
        case .initial:
            break
        case .ready(let data):
            loadMoreButtonVisible = !data.reachedEnd
            
            dataSource.messages = data.items
            markSeenMessage()
            messagesCollectionView.reloadData()
        case .failed(let error):
            print(error)
        case .loading:
            dataSource.messages = []
            messagesCollectionView.reloadData()
        case .loadingMore:
            break
        }
    }
}
