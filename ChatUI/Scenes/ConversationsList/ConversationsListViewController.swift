//
//  ConversationsListViewController.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public class ConversationsListViewController: UIViewController {
    
    weak var coordinator: RootCoordinating?
    
    private let viewModel: ConversationsListViewModeling
    private lazy var tableView = UITableView()
    private lazy var footerLoader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .loadingIndicator
        return indicator
    }()
    
    private lazy var emptyStateView: UIView = {
        let view = EmptyConversationsList.nibInstance
        
        view.buttonAction = { [weak self] in
            self?.coordinator?.emptyStateAction()
        }
        
        return view
    }()
    
    var state: ViewControllerState?
    
    private lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: self.traitCollection.userInterfaceStyle == .dark ? .white : .gray)
        indicator.startAnimating()
        return indicator
    }()

    // swiftlint:disable:next weak_delegate
    private var delegate: Delegate?
    private lazy var dataSource = DataSource(currentUser: viewModel.currentUser)

    init(viewModel: ConversationsListViewModeling) {

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
    
}

// MARK: StatefulViewController
extension ConversationsListViewController: StatefulViewController {
    func viewForState(_ state: ViewControllerState) -> UIView {
        switch state {
        case .empty:
            return emptyStateView
        case .loading:
            return loadingIndicator
        case .loaded:
            return tableView
        case let .error(_, error):
            // TODO: display user friendly error
            let errorLabel = UILabel()
            errorLabel.numberOfLines = 0
            errorLabel.textAlignment = .center
            errorLabel.text = error?.localizedDescription ?? "Unknown error"
            return errorLabel
        }
    }
}

// MARK: Private methods
private extension ConversationsListViewController {
    func setup() {
        title = .conversationsListNavigationTitle
        
        let backButtonImage: UIImage = .backButton
        navigationItem.backBarButtonItem = UIBarButtonItem(image: backButtonImage.withRenderingMode(.alwaysOriginal), style: .plain, target: nil, action: nil)

        view.backgroundColor = .chatBackground
        view.addSubview(tableView)
        tableView.pinToSuperview()
        
        delegate = Delegate(
            didSelectBlock: { [weak self] row in
                guard let conversation = self?.dataSource.items[safe: row] else {
                    return
                }
                
                self?.coordinator?.navigate(to: conversation)
            },
            didReachBottomBlock: { [weak self] in
                self?.viewModel.loadMore()
            },
            footerView: footerLoader
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.separatorStyle = .none
        
        tableView.register(ConversationsListCell.nib, forCellReuseIdentifier: ConversationsListCell.reuseIdentifer)
    }
    
    func toggleTableViewLoader(visible: Bool) {
        footerLoader.isHidden = !visible
        visible ? footerLoader.startAnimating() : footerLoader.stopAnimating()
    }
}

// MARK: ConversationsListViewModelDelegate
extension ConversationsListViewController: ConversationsListViewModelDelegate {
    public func didTransitionToState(_ state: ViewModelingState<ConversationsListState>) {
        
        switch state {
        case .initial:
            break
        case let .ready(state):
            dataSource.items = state.items
            tableView.reloadData()
            toggleTableViewLoader(visible: false)
            
            let newState: ViewControllerState = state.items.isEmpty ? .empty(previous: self.state) : .loaded(previous: self.state)
            setState(newState)
        case let .failed(error):
            setState(.error(previous: self.state, error: error))
        case .loading:
            setState(.loading(previous: self.state))
            dataSource.items = []
            tableView.reloadData()
        case .loadingMore:
            toggleTableViewLoader(visible: true)
        }
    }
}

extension ConversationsListViewController {
    
    // MARK: DataSource
    class DataSource: NSObject, UITableViewDataSource {
        
        var currentUser: User
        var items: [Conversation] = []
        
        init(currentUser: User) {
            self.currentUser = currentUser
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            items.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(of: ConversationsListCell.self, at: indexPath)
            
            cell.model = ConversationsListCellViewModel(conversation: items[indexPath.row], currentUser: currentUser)
            
            return cell
        }
    }
    
    // MARK: Delegate
    class Delegate: NSObject, UITableViewDelegate {
        
        let didSelectBlock: (Int) -> Void
        let didReachBottomBlock: () -> Void
        
        private let footerView: UIView
        
        private let rowHeight: CGFloat = 72
        private let footerHeight: CGFloat = 50
        
        init(didSelectBlock: @escaping (Int) -> Void, didReachBottomBlock: @escaping () -> Void, footerView: UIView) {
            self.didSelectBlock = didSelectBlock
            self.didReachBottomBlock = didReachBottomBlock
            self.footerView = footerView
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            didSelectBlock(indexPath.row)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            rowHeight
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            footerHeight
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            footerView
        }
        
        func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
                didReachBottomBlock()
            }
        }
    }
}
