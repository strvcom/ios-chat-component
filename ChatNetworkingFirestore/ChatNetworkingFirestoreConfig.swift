//
//  ChatNetworkingFirestoreConfiguration.swift
//  ChatNetworkingFirestore
//
//  Created by Tomas Cejka on 3/31/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import FirebaseFirestore

// MARK: - Configuration of firestore network
public struct ChatNetworkingFirestoreConfig {
    let configUrl: String

    public init(configUrl: String) {
        self.configUrl = configUrl
    }
}
