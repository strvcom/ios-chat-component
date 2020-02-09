//
//  Pagination.swift
//  ChatNetworkFirebase
//
//  Created by Daniel Pecher on 09/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import Firebase

struct Pagination {
    var currentStartingDocument: DocumentSnapshot?
    var pageSize = Constants.paginationPageSize
}
