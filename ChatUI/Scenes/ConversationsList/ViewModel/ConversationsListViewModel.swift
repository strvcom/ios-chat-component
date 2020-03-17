//
//  ConversationsListViewModel.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

class ConversationsListViewModel<Core: ChatUICoreServicing> {
    
    private let core: Core
    private(set) var state: ViewModelingState<[Conversation]> = .initial
    private var items = [Conversation]()
    private weak var delegate: ConversationsListViewModelDelegate?
    
    private var listener: ListenerIdentifier?
    
    private(set) var reachedEnd = false
    
    var currentUser: User? {
        core.currentUser
    }
    
    var count: Int {
        items.count
    }
    
    init(core: Core, delegate: ConversationsListViewModelDelegate? = nil) {
        self.core = core
        self.delegate = delegate
    }
    
    deinit {
        guard let listener = listener else {
            return
        }
        
        core.remove(listener: listener)
    }
    
    func load() {
        updateState(.loading)
        
        listener = core.listenToConversations(pageSize: Constants.conversationsPageSize) { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let payload):
                self.items = payload.data
                self.reachedEnd = payload.reachedEnd
                self.updateState(.ready(value: payload.data))
            case .failure(let error):
                self.updateState(.failed(error: error))
            }
        }
    }
    
    func loadMore() {
        guard case .ready = state, reachedEnd == false else {
            return
        }
        
        updateState(.loading)
        
        core.loadMoreConversations()
    }
    
    func item(at index: Int) -> Conversation? {
        items[safe: index]
    }
}

private extension ConversationsListViewModel {
    func updateState(_ state: ViewModelingState<[Conversation]>) {
        self.state = state
        delegate?.didTransitionToState(state)
    }
}
