//
//  MediaContent.swift
//  ChatCore
//
//  Created by Jan on 27/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol MediaContent {
    func normalizedData(completion: (Data) -> Void)
}
