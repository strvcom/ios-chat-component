//
//  UserManaging.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/7/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

/// Defines service for fetching user's details
public protocol UserManaging {
    associatedtype User: UserRepresenting

    /// Function that returns an array of user's details for array of user's ids
    ///
    /// - Parameters:
    ///    - userIds: Unique identifiers of users
    ///    - completion:  Called upon loading all users details (or encountering an error)
    func users(userIds: [EntityIdentifier], completion: @escaping (Result<[User], ChatError>) -> Void)
}
