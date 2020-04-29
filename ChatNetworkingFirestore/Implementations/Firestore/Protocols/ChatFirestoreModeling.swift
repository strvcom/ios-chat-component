//
//  ChatFirestoreModeling.swift
//  ChatApp
//
//  Created by Jan on 23/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

public protocol ChatFirestoreModeling: ChatNetworkModeling where

    NetworkConversation: Decodable,
    NetworkConversation: MembersStoring,
    NetworkConversation.User == NetworkConversation.Member,
    
    NetworkMessage: Decodable,
    
    NetworkMessageSpecification: JSONConvertible,

    NetworkUser: Decodable {}
