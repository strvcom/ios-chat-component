//
//  MessagesListViewController.swift
//  ChatUI
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public class MessagesListViewController<Core: ChatCoreServicing>: UIViewController {
    typealias Conversation = Core.Conversation
    typealias Message = Core.Message
    typealias MessageSpecification = Core.MessageSpecification
    
    let core: Core
    let conversation: Conversation
    fileprivate let dataSource = DataSource()
    
    private var tableView: UITableView!
    private var listener: ChatListener?
    
    init(conversation: Conversation, core: Core) {
        self.core = core
        self.conversation = conversation

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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Send", style: .plain, target: self, action: #selector(self.send))
        
        tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ListCell.self, forCellReuseIdentifier: ListCell.reuseIdentifier)
        tableView.dataSource = dataSource
        view.addSubview(tableView)
        
        view.addConstraints([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor)
            ])

        listener = core.listenToConversation(with: conversation.id) { [weak self] result in
            switch result {
            case .success(let messages):
                self?.dataSource.messages = messages
                self?.tableView.reloadData()
            case .failure(let error):
                print(error)
            }
        }
    }
    
    @objc private func send() {
        guard let specification = MessageSpecification.specification(for: "Bla") else {
            return
        }
        
        core.send(message: specification, to: conversation.id) { result in
            print(result)
        }
    }
}

extension MessagesListViewController {
    class DataSource: NSObject, UITableViewDataSource {
        var messages: [Message] = []
        
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return messages.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: ListCell.reuseIdentifier, for: indexPath)
            
            let message = messages[indexPath.row]
            
            cell.textLabel?.text = message.id
            cell.detailTextLabel?.text = message.userId
            
            return cell
        }
    }
}
