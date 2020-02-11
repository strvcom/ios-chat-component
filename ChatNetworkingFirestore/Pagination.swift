//
//  Pagination.swift
//  ChatApp
//
//  Created by Daniel Pecher on 11/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import ChatCore
import Firebase

struct Pagination<T: Decodable> {
    var updateBlock: ((Result<[T], ChatError>) -> Void)?
    var listener: ChatListener?
    var pageSize = Constants.defaultPageSize
    var itemsLoaded = Constants.defaultPageSize
    
    mutating func nextPage() {
        itemsLoaded += pageSize
    }
}
