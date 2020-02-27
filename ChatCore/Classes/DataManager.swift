//
//  DataManager.swift
//  ChatApp
//
//  Created by Daniel Pecher on 20/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

struct DataManager {
    private var itemCount = 0
    private var pageSize: Int
    var reachedEnd = false
    
    init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    mutating func update<T>(data: [T]) {
        reachedEnd = reachedEnd || itemCount == data.count || data.count % pageSize != 0
        itemCount = data.count
    }
}
