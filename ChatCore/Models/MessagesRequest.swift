//
//  MessagesRequest.swift
//  STRVChatCore
//
//  Created by Daniel Pecher on 23.02.2021.
//

import Foundation

public struct MessagesRequest {
    public let messageId: EntityIdentifier
    public let direction: LoadingDirection
    public let count: Int
    public let includeInResult: Bool
    
    public init(messageId: EntityIdentifier, direction: LoadingDirection, count: Int, includeInResult: Bool) {
        self.messageId = messageId
        self.direction = direction
        self.count = count
        self.includeInResult = includeInResult
    }
}
