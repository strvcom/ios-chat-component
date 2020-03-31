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
    private(set) var state: ViewModelingState<ConversationsListState> = .initial
    weak var delegate: ConversationsListViewModelDelegate?
    
    private var listener: ListenerIdentifier?
    
    var currentUser: User? {
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
        updateState(.loading)
        
        listener = core.listenToConversations { [weak self] result in
            guard let self = self else {
                return
            }
            
            switch result {
            case .success(let payload):
                self.updateState(
                    .ready(
                        value: ConversationsListState(
                            items: payload.data,
                            reachedEnd: payload.reachedEnd
                        )
                    )
                )
            case .failure(let error):
                self.updateState(.failed(error: error))
            }
        }
    }
    
    func loadMore() {
        guard case let .ready(data) = state, !data.reachedEnd else {
            return
        }
        
        updateState(.loadingMore)
        
        core.loadMoreConversations()
    }
}

private extension ConversationsListViewModel {
    func updateState(_ state: ViewModelingState<ConversationsListState>) {
        self.state = state
        delegate?.didTransitionToState(state)
    }
}
