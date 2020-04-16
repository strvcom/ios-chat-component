//
//  UserManaging.swift
//  ChatNetworkingFirestore
//
//  Created by Tomas Cejka on 4/7/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import ChatCore

// MARK: - Default firestore implementation of user managing
public class UserManagerFirestore: UserManaging {

    private let database: Firestore
    private var users: [UserFirestore] = []
    private var currentUserIds: Set<EntityIdentifier> = []
    private var listener: ListenerRegistration?

    deinit {
        print("\(self) released")
        listener?.remove()
    }

    public init(config: ChatNetworkingFirestoreConfig) {
        // setup from config
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }

        let appName = UUID().uuidString
        FirebaseApp.configure(name: appName, options: options)
        guard let firebaseApp = FirebaseApp.app(name: appName) else {
            fatalError("Can't configure Firebase app \(appName)")
        }

        database = Firestore.firestore(app: firebaseApp)
    }

    public func users(userIds: [EntityIdentifier], completion: @escaping (Result<[UserFirestore], ChatError>) -> Void) {

        // get unique ids
        let userIdsSet = Set(userIds)

        // compare to current set
        if userIdsSet.isSubset(of: currentUserIds) {
            completion(.success(users))
        } else {
            // reset
            currentUserIds = userIdsSet
            listener?.remove()

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
}
