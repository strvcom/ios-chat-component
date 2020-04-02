//
//  ConversationsListViewModeling.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ConversationsListViewModeling: AnyObject {
    var delegate: ConversationsListViewModelDelegate? { get set }

    func load()
    func loadMore()
}
