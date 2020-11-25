//
//  UploadPathSpecifying.swift
//  STRVChatCore
//
//  Created by Daniel Pecher on 25/11/2020.
//

import Foundation

public protocol UploadPathSpecifying {
    /// return nil to use default path
    var uploadPath: String? { get }
}
