//
//  DocumentSnapshot+Decoding.swift
//  ChatNetworkingFirestore
//
//  Created by Jan on 04/08/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import FirebaseFirestore

extension DocumentSnapshot {
    func decode<T: Decodable>(to type: T.Type, with decoder: JSONDecoder) throws -> T {
        var json = self.data() ?? [:]
        json[Constants.identifierAttributeName] = self.documentID
        json.replaceFirebaseTimestamps()
        
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        
        return try decoder.decode(type, from: data)
    }
}

extension Dictionary where Key == String, Value == Any {
    mutating func replaceFirebaseTimestamps() {
        for (key, value) in self {
            if let timestamp = value as? Timestamp {
                self[key] = timestamp.dateValue().timeIntervalSince1970
            } else if var dict = value as? [String: Any] {
                dict.replaceFirebaseTimestamps()
                self[key] = dict
            }
        }
    }
}
