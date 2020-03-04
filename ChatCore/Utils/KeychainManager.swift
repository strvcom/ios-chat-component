//
//  KeychainManager.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/3/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import KeychainSwift

// MARK: - KeychainKeys
enum KeychainKey: String {
    case unsentMessages = "com.strv.chatcore.unsentmesssages"
}

final class KeychainManager {
    let keychain = KeychainSwift()
}

// MARK: - Keychaing base methods
extension KeychainManager {
    func store(value: String, forKey key: KeychainKey) {
        // store new value
        keychain.set(value, forKey: key.rawValue)
    }

    func value(forKey key: KeychainKey) -> String? {
        return keychain.get(key.rawValue)
    }

    func removeValue(forKey key: KeychainKey) {
        keychain.delete(key.rawValue)
    }
}
