//
//  ConversationsListViewModel.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

class ConversationsListViewModel: ConversationsListViewModeling {
    
    weak var delegate: ConversationsListViewModelDelegate?
    
    private let dataFetcher: DataFetching

    init(dataFetcher: DataFetching) {
        self.dataFetcher = dataFetcher
    }
    
    func load() {
        dataFetcher.load { [weak self] in self?.updateState(state: $0) }
    }
    
    func loadMore() {
        dataFetcher.loadMore { [weak self]  in self?.updateState(state: $0) }
    }
}

private extension ConversationsListViewModel {
    func updateState(state: DataFetching.ConversationState) {
        delegate?.didTransitionToState(state)
    }
}
