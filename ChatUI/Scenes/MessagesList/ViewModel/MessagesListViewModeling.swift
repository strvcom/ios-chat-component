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

protocol MessagesListViewModeling: AnyObject {
    var delegate: MessagesListViewModelDelegate? { get set }

    func load()
    func loadMore()
    func updateSeenMessage(_ message: MessageKitType)
    func send(message: MessageSpecification, completion: @escaping (Result<MessageKitType, ChatError>) -> Void)
    func messageBottomLabelHeight(for message: MessageType) -> CGFloat
    func messageBottomLabelText(for message: MessageType) -> String
}
