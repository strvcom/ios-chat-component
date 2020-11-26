//
//  JSONDecoder+Convenience.swift
//  ChatNetworkingFirestore
//
//  Created by Jan on 18.11.2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public extension JSONDecoder {
    static var chatDefault: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
}
