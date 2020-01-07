//
//  Error.swift
//  ChatCore
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public enum ChatError: Error {
    case networking(error: Error)
    case serialization(error: Error)
    case `internal`(message: String)
}
