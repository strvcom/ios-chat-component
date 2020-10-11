//
//  DataManager.swift
//  ChatApp
//
//  Created by Daniel Pecher on 20/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

struct DataManager {
    private var pageSize: Int
    var reachedEnd = false

    private var lastHash: Int?

    init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    mutating func update<T: Hashable>(count: Int, hashData: [T]) {
        let hashValue = hashData.hashValue

        // if data havent changed or page size is not dividable by page count
        reachedEnd = hashValue == lastHash || count % pageSize != 0
        lastHash = hashValue
    }
}
