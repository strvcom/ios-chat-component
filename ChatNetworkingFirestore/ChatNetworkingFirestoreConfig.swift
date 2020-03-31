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

    // allow pass firebase configuration file url or firestore reference itself to avoid multiple referencing and crashes
    public enum ConfigurationType {
        case configUrl(String)
        case database(Firestore)
    }

    let type: ConfigurationType

    public init(type: ConfigurationType) {
        self.type = type
    }
}
