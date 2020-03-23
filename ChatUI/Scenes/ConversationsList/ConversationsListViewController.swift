//
//  ConversationsListViewController.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import MessageKit

public class ConversationsListViewController: UIViewController {
    
    var coordinator: RootCoordinating?
    
    private var viewModel: ConversationsListViewModeling
    private lazy var tableView = UITableView()
    private lazy var dataSource = DataSource(viewModel: viewModel)
    private lazy var footerLoader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .loadingIndicator
        return indicator
    }()
    
    private lazy var sender: Sender? = {
        guard let currentUser = viewModel.currentUser else {
            return nil
        }
        
        return Sender(id: currentUser.id, displayName: currentUser.name)
    }()
    
    // swiftlint:disable:next weak_delegate
    private var delegate: Delegate?
    
    init(viewModel: ConversationsListViewModeling) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        setup()
        viewModel.delegate = self
        viewModel.load()
    }
}

// MARK: Private methods
private extension ConversationsListViewController {
    func setup() {
        view.addSubview(tableView)
        tableView.fill(view)
        
        delegate = Delegate(
            didSelectBlock: { [weak self] row in
                guard
                    let self = self,
                    let conversation = self.viewModel.item(at: row),
                    let sender = self.sender else {
                    return
                }
                
                self.coordinator?.navigate(to: conversation, sender: sender)
            },
            didReachBottomBlock: { [weak self] in
                self?.viewModel.loadMore()
            },
            footerView: footerLoader
        )
        
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        tableView.separatorColor = .clear
        
        tableView.register(
            UINib(
                nibName: ConversationsListCell.reuseIdentifier,
                bundle: Bundle(for: ConversationsListCell.self)
            ),
            forCellReuseIdentifier: ConversationsListCell.reuseIdentifier
        )
    }
    
    func startLoading() {
        footerLoader.isHidden = false
        footerLoader.startAnimating()
    }
    
    func stopLoading() {
        footerLoader.isHidden = true
        footerLoader.stopAnimating()
    }
}

// MARK: ConversationsListViewModelDelegate
extension ConversationsListViewController: ConversationsListViewModelDelegate {
    public func didTransitionToState(_ state: ViewModelingState<[Conversation]>) {
        
        switch state {
        case .initial:
            break
        case .ready:
            stopLoading()
            tableView.reloadData()
        case let .failed(error):
            // TODO: UI error
            print(error)
            stopLoading()
        case .loading:
            startLoading()
        }
    }
}

extension ConversationsListViewController {
    
    // MARK: DataSource
    class DataSource: NSObject, UITableViewDataSource {
        
        private let viewModel: ConversationsListViewModeling
        
        init(viewModel: ConversationsListViewModeling) {
            self.viewModel = viewModel
        }
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            viewModel.itemCount
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueCell(cellType: ConversationsListCell.self, for: indexPath)

            if let user = viewModel.currentUser, let conversation = viewModel.item(at: indexPath.row) {
                cell.model = ConversationsListCellViewModel(
                    conversation: conversation,
                    currentUser: user
                )
            }
            
            cell.selectionStyle = .none
            
            return cell
        }
    }
    
    // MARK: Delegate
    class Delegate: NSObject, UITableViewDelegate {
        
        let didSelectBlock: (Int) -> Void
        let didReachBottomBlock: () -> Void
        
        private let footerView: UIView
        
        private let heightRow: CGFloat = 72
        
        init(didSelectBlock: @escaping (Int) -> Void, didReachBottomBlock: @escaping () -> Void, footerView: UIView) {
            self.didSelectBlock = didSelectBlock
            self.didReachBottomBlock = didReachBottomBlock
            self.footerView = footerView
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            didSelectBlock(indexPath.row)
        }
        
        func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            heightRow
        }
        
        func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
            50
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            footerView
        }
        
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let height = scrollView.frame.size.height
            let contentYoffset = scrollView.contentOffset.y
            let distanceFromBottom = scrollView.contentSize.height - contentYoffset
            let triggerDistance = CGFloat(50)
            
            if distanceFromBottom < height - triggerDistance {
                didReachBottomBlock()
            }
        }
    }
}
