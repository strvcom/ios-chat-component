//
//  JSONConvertible.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// An object that conforms to this protocol can be converted to `ChatJSON` i.e. `[String: Any]`
public protocol JSONConvertible {
    /// JSON representation of the object
    ///
    /// DISCUSSION:
    /// Values of the resulting json can be of any data type that can be stored in json objects
    /// Besides these data types the result can contain also values of `MediaContent` that are automatically uploaded to a specified network data stroge and the value of `MediaContent` type is replaced by an result url of the upload request
    var json: ChatJSON { get }
}
