//
//  MediaContent.swift
//  ChatCore
//
//  Created by Jan on 27/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// An object that conforms to this protocol represents media content and be converted to data
///
/// Resulting data are uploaded to a specified network data storage
public protocol MediaContent {
    /// Data representation of the object. The data must be suitable for upload i.e. their size should normalized to save network traffic
    /// - Parameter completion: Completion block that is called once the conversion of the object to data is finished
    func normalizedData(completion: (Data) -> Void)
}
