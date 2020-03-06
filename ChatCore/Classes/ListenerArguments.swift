//
//  ListenerArguments.swift
//  ChatApp
//
//  Created by Daniel Pecher on 06/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public enum ListenerArguments: Hashable {
    case conversations(pageSize: Int)
    case messages(pageSize: Int, conversationId: ObjectIdentifier)
}
