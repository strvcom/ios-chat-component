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

public class UserManagerFirestore: UserManaging {
    let database: Firestore

    private var users: [UserFirestore] = []
    private var listener: ListenerRegistration?

    public init(database: Firestore) {
        self.database = database
    }

    // TODO listeners ala core
    public func users(userIds: [ObjectIdentifier], completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) {

        let query = database.collection(Constants.usersPath).whereField(FieldPath.documentID(), in: userIds)
        listener = query.addSnapshotListener(includeMetadataChanges: false) { (snapshot, error) in
            if let snapshot = snapshot {
                let list: [UserFirestore] = snapshot.documents.compactMap {
                    do {
                        return try $0.data(as: UserFirestore.self)
                    } catch {
                        print("Couldn't decode document:", error)
                        return nil
                    }
                }
                self.users = list
                completion(.success(list))
            } else if let error = error {
                completion(.failure(.networking(error: error)))
            } else {
                completion(.failure(.internal(message: "Unknown")))
            }
        }
    }
}
