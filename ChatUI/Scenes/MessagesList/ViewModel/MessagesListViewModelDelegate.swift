//
//  MessagesListViewModelDelegate.swift
//  ChatUI
//
//  Created by Daniel Pecher on 02/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol MessagesListViewModelDelegate: AnyObject {
    func stateDidChange()
}
