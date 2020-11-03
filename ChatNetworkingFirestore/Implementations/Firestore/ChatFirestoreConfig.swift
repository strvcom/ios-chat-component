//
//  ChatFirestoreConfig.swift
//  ChatFirestore
//
//  Created by Tomas Cejka on 3/31/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import FirebaseFirestore

// MARK: - Configuration of firestore network
public struct ChatFirestoreConfig {
    let configUrl: String
    let constants: ChatFirestoreConstants
    let updateLastMessage: Bool

    public init(configUrl: String, constants: ChatFirestoreConstants = ChatFirestoreConstants(), updateLastMessage: Bool = true) {
        self.configUrl = configUrl
        self.constants = constants
        self.updateLastMessage = updateLastMessage
    }
}
