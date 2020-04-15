//
//  MessagesListViewModeling.swift
//  ChatUI
//
//  Created by Daniel Pecher on 02/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import MessageKit

public typealias MessagesListState = ListState<MessageKitType>

protocol MessagesListViewModeling: AnyObject {
    var delegate: MessagesListViewModelDelegate? { get set }
    var state: ViewModelingState<MessagesListState> { get }
    var currentUser: User { get }
    var partner: User? { get }

    func load()
    func loadMore()
    func updateSeenMessage(_ message: MessageKitType)
    func send(message: MessageSpecification, completion: @escaping (Result<MessageKitType, ChatError>) -> Void)
    func seen(message: EntityIdentifier) -> Bool
    func seenLabel(for: EntityIdentifier) -> String
    func timeLabel(for date: Date) -> String
}
