//
//  ChatFirestoreModeling.swift
//  ChatApp
//
//  Created by Jan on 23/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

/// Extension of `ChatNetworkModeling` with additional requirements for models used in `ChatFirestore`
public protocol ChatFirestoreModeling: ChatNetworkModeling where
    // Additional requirements for the conversation model
    NetworkConversation: Decodable,
    // Additional requirements for the message model
    NetworkMessage: Decodable,
    // Additional requirements for the message specification model
    NetworkMessageSpecification: JSONConvertible & UploadPathSpecifying,
    // Additional requirements for the user model
    NetworkUser: Decodable,
    // Additional requirements for the seen item
    NetworkSeenItem: Decodable {}
