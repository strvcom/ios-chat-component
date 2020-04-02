//
//  ConversationsListViewModelDelegate.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ConversationsListViewModelDelegate: AnyObject {
    func didTransitionToState(_ state: ViewModelingState<ListState<Conversation>>)
}
