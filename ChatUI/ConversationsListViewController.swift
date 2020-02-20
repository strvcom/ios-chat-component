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

public class ConversationsListViewController<Core: ChatUICoreServicing>: UIViewController {
    let core: Core
    
    private let dataSource = DataSource()
    
    // swiftlint:disable:next weak_delegate
    private var delegate: Delegate?
    
    private lazy var tableView = UITableView()
    private var listener: ChatListener?

    // FIXME: this is just a temporary solution
    private var sender = Sender(id: "", displayName: "")
    
    init(core: Core) {
        self.core = core

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
        
        delegate = Delegate(
            didSelectBlock: { [weak self] row in
                guard let self = self else {
                    return
                }
                
                let conversation = self.dataSource.conversations[row]
                let controller = MessagesListViewController(conversation: conversation, core: self.core, sender: self.sender)
                self.navigationController?.pushViewController(controller, animated: true)
            },
            loadMoreBlock: { [weak self] in
                guard let self = self else {
                    return
                }
                self.core.loadMoreConversations()
            }
        )
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        tableView.dataSource = dataSource
        tableView.delegate = delegate
        view.addSubview(tableView)
        
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])

        
        listener = core.listenToConversations { result in
            switch result {
            case .success(let conversations):
                self.dataSource.conversations = conversations

                if let user = self.core.currentUser {
                    self.sender = Sender(id: user.id, displayName: user.name)
                }

                self.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createTestConversation))
    }
    
    // FIXME: Remove this temporary method when UI for conversation creating is ready
    // Creates a test conversation with all current users as members
    // just to have something to see in the conversation list.
    // Can be removed when we have UI for starting new conversation.
    @objc public func createTestConversation() {
        NotificationCenter.default.post(name: NSNotification.Name("TestConversation"), object: nil)
    }
}

extension ConversationsListViewController {
    class DataSource: NSObject, UITableViewDataSource {
        var conversations: [Conversation] = []

        func conversationTitle(_ conversation: Conversation) -> String {
            let title = conversation.members.compactMap { $0.name }.joined(separator: ",")
            return title.isEmpty ? "Conversation Title" : title
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return conversations.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath)
            
            let conversation = conversations[indexPath.row]
            
            cell.textLabel?.text = conversationTitle(conversation)
            cell.detailTextLabel?.text = "message"
            
            return cell
        }
    }
    
    class Delegate: NSObject, UITableViewDelegate {
        let didSelectBlock: (Int) -> Void
        let loadMoreBlock: () -> Void
        
        init(didSelectBlock: @escaping (Int) -> Void, loadMoreBlock: @escaping () -> Void) {
            self.didSelectBlock = didSelectBlock
            self.loadMoreBlock = loadMoreBlock
        }
        
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            didSelectBlock(indexPath.row)
        }
        
        func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
            let button = UIButton()
            button.setTitle("Load more...", for: .normal)
            button.setTitleColor(.systemBlue, for: .normal)
            button.addTarget(self, action: #selector(loadMoreTapped), for: .touchUpInside)
            return button
        }
        
        @objc func loadMoreTapped() {
            loadMoreBlock()
        }
    }
}
