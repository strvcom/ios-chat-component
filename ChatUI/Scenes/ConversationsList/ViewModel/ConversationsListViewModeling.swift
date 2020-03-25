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
    var currentUser: User? { get }
    var sender: Sender? { get }
    var itemCount: Int { get }
    var delegate: ConversationsListViewModelDelegate? { get set }
    var state: ViewModelingState<[Conversation]> { get }
    var reachedEnd: Bool { get }
    
    func load()
    func loadMore()
    func item(at index: Int) -> Conversation?
}
