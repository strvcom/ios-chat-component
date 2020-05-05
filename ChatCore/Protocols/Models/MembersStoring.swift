//
//  MembersStoring.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Objects e.g. conversations that keep reference of their members indirectly through member ids
public protocol MembersStoring {
    associatedtype Member
    
    /// Identifiers of members relevant to the object
    var memberIds: [EntityIdentifier] { get }
    
    /// Set member objects specified by `memberIds`
    /// - Parameter members: Member objects
    mutating func setMembers(_ members: [Member])
}
