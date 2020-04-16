//
//  ChatNetworkingWithTyping.swift
//  ChatCore
//
//  Created by Tomas Cejka on 4/15/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public protocol ChatNetworkingWithTypingUsers {

    associatedtype User: UserRepresenting

    func setTypingUser(user id: EntityIdentifier, in conversation: EntityIdentifier)

    func removeTypingUser(user id: EntityIdentifier, in conversation: EntityIdentifier)

    func listenToTypingUsers(in conversation: EntityIdentifier, completion: @escaping (Result<[User], ChatError>) -> Void)
}

extension ChatNetworkServicing where Self: ChatNetworkingWithTypingUsers {
    typealias User = UserManager.User
}
