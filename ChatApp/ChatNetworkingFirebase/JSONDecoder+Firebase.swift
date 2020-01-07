//
//  JSONDecoder+Firebase.swift
//  ChatNetworkingFirebase
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import Firebase

extension JSONDecoder {
    func decode<T: Decodable>(snapshot: QuerySnapshot) throws -> [T] {
        return try snapshot.documents.map({ try self.decode(document: $0) })
    }
    
    func decode<T: Decodable>(document: QueryDocumentSnapshot) throws -> T {
        var json = document.data()
        json[Constants.defaultIdAttributeName] = document.documentID
        
        return try decode(json: json)
    }
    
    func decode<T: Decodable>(json: [String: Any]) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: json, options: [])
        let object = try self.decode(T.self, from: data)
        
        return object
    }
}
