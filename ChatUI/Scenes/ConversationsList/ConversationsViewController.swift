//
//  ConversationsListViewController.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public class ConversationsViewController<ViewModel: ConversationsListViewModeling>: ConversationsListViewController, UITableViewDataSource, UITableViewDelegate {
    public weak var actionsDelegate: ConversationsListActionsDelegate?
    
    private let viewModel: ViewModel
    private lazy var tableView = UITableView()
    private lazy var footerLoader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .loadingIndicator
        return indicator
    }()
    private let rowHeight: CGFloat = 72
    private let footerHeight: CGFloat = 50

    private lazy var emptyStateView: EmptyConversationsList = {
        let view = EmptyConversationsList.nibInstance
        
        view.buttonAction = { [weak self] in
            guard let self = self else {
                return
            }
            
            self.actionsDelegate?.didTapOnEmptyListAction?(in: self)
        }
        
        return view
    }()
    
    var state: ViewControllerState?
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: self.traitCollection.userInterfaceStyle == .dark ? .white : .gray)
        indicator.startAnimating()
        return indicator
    }()

    private var conversations: [ViewModel.Conversation] = []

    init(viewModel: ViewModel) {

        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
        
        self.viewModel.delegate = self
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
        viewModel.load()
    }
    
    // MARK: - UITableViewDataSource
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        conversations.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(of: ConversationsListCell.self, at: indexPath)
        
        cell.model = ConversationsListCellViewModel(conversation: conversations[indexPath.row], currentUser: viewModel.currentUser)
        
        return cell
    }

    // MARK: - UITableViewDelegate
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let conversation = conversations[safe: indexPath.row] else {
            return
        }
        
        self.actionsDelegate?.didSelectConversation(conversationId: conversation.id, in: self)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        rowHeight
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        footerHeight
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        footerLoader
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            viewModel.loadMore()
        }
    }
}

// MARK: StatefulViewController
extension ConversationsViewController: StatefulViewController {
    var contentView: UIView? {
        switch state {
        case .empty:
            return emptyStateView
        case .loading:
            return loadingIndicator
        case .loaded:
            return tableView
        case let .error(error):
            return ErrorView(message: error?.localizedDescription ?? "Unknown error")
        case .none:
            return nil
        }
    }
}

// MARK: Private methods
private extension ConversationsViewController {
    func setup() {
        title = .conversationsListNavigationTitle
        
        let backButtonImage: UIImage = .backButton
        navigationItem.backBarButtonItem = UIBarButtonItem(image: backButtonImage.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)

        view.backgroundColor = .chatBackground
        view.addSubview(tableView)
        tableView.pinToSuperview()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        
        tableView.register(ConversationsListCell.nib, forCellReuseIdentifier: ConversationsListCell.reuseIdentifer)
    }
    
    func toggleTableViewLoader(visible: Bool) {
        footerLoader.isHidden = !visible
        visible ? footerLoader.startAnimating() : footerLoader.stopAnimating()
    }
}

// MARK: ConversationsListViewModelDelegate
extension ConversationsViewController: ConversationsListViewModelDelegate {
    public func stateDidChange() {
        
        switch viewModel.state {
        case .initial:
            break
        case let .ready(state):
            conversations = state.items
            tableView.reloadData()
            toggleTableViewLoader(visible: false)
            
            let newState: ViewControllerState = state.items.isEmpty ? .empty : .loaded
            setState(newState)
        case let .failed(error):
            setState(.error(error: error))
        case .loading:
            setState(.loading)
            conversations = []
            tableView.reloadData()
        case .loadingMore:
            toggleTableViewLoader(visible: true)
        }
    }
}
