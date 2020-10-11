//
//  ConversationsListViewModel.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

class ConversationsListViewModel<Core: ChatUICoreServicing>: ConversationsListViewModeling {
    private let core: Core
    weak var delegate: ConversationsListViewModelDelegate?

    private(set) var state: ViewModelingState<ConversationsListState> = .initial {
        didSet {
            delegate?.stateDidChange()
        }
    }

    private var listener: ListenerIdentifier?
    
    var currentUser: Core.UIModels.UIUser {
        core.currentUser
    }
    
    init(core: Core) {
        self.core = core
    }
    
    deinit {
        guard let listener = listener else {
            return
        }
        
        core.remove(listener: listener)
    }
    
    func load() {
        state = .loading
        
        if let existingListener = listener {
            core.remove(listener: existingListener)
        }
        
        listener = core.listenToConversations { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let payload):
                self.state = .ready(
                        value: ConversationsListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                )
            case .failure(let error):
                self.state = .failed(error: error)
            }
        }
    }
    
    func loadMore() {
        guard case let .ready(data) = state, !data.reachedEnd else {
            return
        }
        
        state = .loadingMore
        
        core.loadMoreConversations()
    }
}
