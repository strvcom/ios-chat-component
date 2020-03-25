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
    
    weak var coordinator: RootCoordinating?
    
    private let viewModel: ConversationsListViewModeling
    private lazy var tableView = UITableView()
    private lazy var dataSource = DataSource(viewModel: viewModel)
    private lazy var footerLoader: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.color = .loadingIndicator
        return indicator
    }()
    
    private lazy var sender: Sender? = viewModel.sender
    
    // swiftlint:disable:next weak_delegate
    private var delegate: Delegate?
    
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
        tableView.separatorStyle = .none
        
        tableView.register(ConversationsListCell.nib, forCellReuseIdentifier: ConversationsListCell.reuseIdentifer)
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
            let cell = tableView.dequeueReusableCell(of: ConversationsListCell.self, at: indexPath)

            if let user = viewModel.currentUser, let conversation = viewModel.item(at: indexPath.row) {
                cell.model = ConversationsListCellViewModel(
                    conversation: conversation,
                    currentUser: user
                )
            }
            
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
