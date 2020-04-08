//
//  UserManaging.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/7/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

///
public protocol UserManaging {
    associatedtype User: UserRepresenting

    func users(userIds: [EntityIdentifier], completion: @escaping (Result<[User], ChatError>) -> Void)
}
