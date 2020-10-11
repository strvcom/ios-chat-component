//
//  File.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/21/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - States of message representation
public enum MessageState {
    /// to indicate message is sending
    case sending
    /// standard state when message is sent sucessfully
    case sent
    /// state indicates message couldn't be send, specially because of network error
    case failedToBeSend
}
