//
//  RootCoordinating.swift
//  ChatUI
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import MessageKit

protocol RootCoordinating {
    func navigate(to conversation: Conversation, sender: Sender)
}
