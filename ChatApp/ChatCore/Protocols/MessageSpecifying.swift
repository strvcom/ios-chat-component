//
//  MessageSpecifying.swift
//  ChatCore
//
//  Created by Jan Schwarz on 06/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol MessageSpecifying {
    // Get desired message reprentation when sending a new message
    static func specification(for data: Any) -> Self?
}
