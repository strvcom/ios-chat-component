//
//  Pagination.swift
//  ChatApp
//
//  Created by Daniel Pecher on 11/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore

struct Pagination<T: Decodable> {
    var updateBlock: ((Result<[T], ChatError>) -> Void)?
    var listener: ListenerIdentifier?
    var pageSize: Int
    var itemsLoaded: Int
    
    init(updateBlock: ((Result<[T], ChatError>) -> Void)?, listener: ListenerIdentifier?, pageSize: Int) {
        self.updateBlock = updateBlock
        self.listener = listener
        self.pageSize = pageSize
        self.itemsLoaded = pageSize
    }
    
    mutating func nextPage() {
        guard pageSize > 0 else {
            fatalError("Pagination hasn't been initialized.")
        }
        
        itemsLoaded += pageSize
    }
    
    static var empty: Pagination {
        Pagination(updateBlock: nil, listener: nil, pageSize: 0)
    }
}
