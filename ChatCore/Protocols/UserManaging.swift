//
//  UserManaging.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/7/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol UserManaging {

    associatedtype U: UserRepresenting

    func users(userIds: [ObjectIdentifier], completion: @escaping (Result<[U], ChatError>) -> Void)
}
