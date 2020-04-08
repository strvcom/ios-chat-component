//
//  UserManaging.swift
//  ChatNetworkingFirestore
//
//  Created by Tomas Cejka on 4/7/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import FirebaseFirestore
import ChatCore

// MARK: - Default firestore implementation of user managing
public class UserManagerFirestore: UserManaging {
    let database: Firestore

    private var users: [Listener: [UserFirestore]] = [:]
    private var listeners: [Listener: ListenerRegistration] = [:]

    public init(database: Firestore) {
        self.database = database
    }

    public func users(userIds: [EntityIdentifier], completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) {

        let listener = Listener.users(userIds: userIds)

        if listeners[listener] == nil {
            let query = database.collection(Constants.usersPath).whereField(FieldPath.documentID(), in: userIds)
            let networkListener = query.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
                if let snapshot = snapshot {
                    let list: [UserFirestore] = snapshot.documents.compactMap {
                        do {
                            return try $0.data(as: UserFirestore.self)
                        } catch {
                            print("Couldn't decode document:", error)
                            return nil
                        }
                    }
                    self.users[listener] = list
                    completion(.success(list))
                } else if let error = error {
                    completion(.failure(.networking(error: error)))
                } else {
                    completion(.failure(.internal(message: "Unknown")))
                }
            }
            listeners[listener] = networkListener
        } else if let users = users[listener] {
            completion(.success(users))
        }
    }
}
