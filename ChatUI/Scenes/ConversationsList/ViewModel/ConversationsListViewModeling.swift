//
//  ConversationsListViewModeling.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import MessageKit

public protocol ConversationsListViewModeling: AnyObject {
    var sender: Sender? { get }
    var delegate: ConversationsListViewModelDelegate? { get set }
    var state: ViewModelingState<ConversationsListState> { get }
    
    func load()
    func loadMore()
}
