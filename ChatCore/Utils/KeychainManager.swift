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

// MARK: - Keychain for messages
extension KeychainManager {
    func storeUnsentMessage<T: Cachable & MessageSpecifying>(_ message: Message<T>) {
        var unsentMessages: [Message<T>] = []
        if let unsentMessagesData: [Message<T>] = object(forKey: .unsentMessages) {
            unsentMessages = unsentMessagesData
        }

        unsentMessages.append(message)
        storeObject(object: unsentMessages, forKey: .unsentMessages)
    }

    func unsentMessages<T: Cachable & MessageSpecifying>() -> [Message<T>] {
        let messages: [Message<T>] = object(forKey: .unsentMessages) ?? []
        // remove all from cache, those will be saved again if fails
        remove(forKey: .unsentMessages)
        return messages
    }
}

// MARK: - Keychaing base methods
extension KeychainManager {
    func storeString(value: String, forKey key: KeychainKey) {
        // store new value
        keychain.set(value, forKey: key.rawValue)
    }

    func string(forKey key: KeychainKey) -> String? {
        return keychain.get(key.rawValue)
    }

    func data(forKey key: KeychainKey) -> Data? {
        return keychain.getData(key.rawValue)
    }

    func storeData(value: Data, forKey key: KeychainKey) {
        keychain.set(value, forKey: key.rawValue)
    }

    func remove(forKey key: KeychainKey) {
        keychain.delete(key.rawValue)
    }

    func object<T: Codable>(forKey key: KeychainKey) -> T? {
        guard let objectData = data(forKey: key) else {
            return nil
        }

        let decoder = JSONDecoder()
        do {
            let object = try decoder.decode(T.self, from: objectData)
            return object
        } catch {
            print(error.localizedDescription)
        }

        return nil
    }

    func storeObject<T: Codable>(object: T, forKey key: KeychainKey) {
        let encoder = JSONEncoder()

        do {
            let data = try encoder.encode(object)
            storeData(value: data, forKey: key)
        } catch {
            print(error.localizedDescription)
        }
    }
}