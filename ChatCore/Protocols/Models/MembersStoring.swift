//
//  MembersStoring.swift
//  ChatCore
//
//  Created by Jan on 24/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol MembersStoring {
    associatedtype Member

    var memberIds: [EntityIdentifier] { get }

    mutating func setMembers(_ members: [Member])
}
