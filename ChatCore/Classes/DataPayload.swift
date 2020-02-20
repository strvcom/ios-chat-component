//
//  DataPayload.swift
//  ChatApp
//
//  Created by Daniel Pecher on 20/02/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public struct DataPayload<T> {
    public let data: T
    public let reachedEnd: Bool
}
