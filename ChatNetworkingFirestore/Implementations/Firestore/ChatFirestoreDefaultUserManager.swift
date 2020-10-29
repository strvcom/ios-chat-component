//
//  ChatFirestoreDefaultUserManager.swift
//  ChatFirestore
//
//  Created by Tomas Cejka on 4/7/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import FirebaseCore
import FirebaseFirestore
import ChatCore

// MARK: - Default firestore implementation of user managing
public class ChatFirestoreDefaultUserManager<User: UserRepresenting>: ChatFirestoreUserManager<User> where User: Decodable {

    private let config: ChatFirestoreConfig
    private let decoder: JSONDecoder
    private let database: Firestore
    private var users: [User] = []
    private var currentUserIds: Set<EntityIdentifier> = []
    private var listener: ListenerRegistration?
    
    private var usersPath: String {
        config.constants.users.path
    }

    deinit {
        print("\(self) released")
        listener?.remove()
    }

    public init(config: ChatFirestoreConfig, decoder: JSONDecoder) {
        self.config = config
        self.decoder = decoder
        
        // setup from config
        guard let options = FirebaseOptions(contentsOfFile: config.configUrl) else {
            fatalError("Can't configure Firebase")
        }

        let app: FirebaseApp?
        
        if let existingInstance = FirebaseApp.app() {
            app = existingInstance
        } else {
            let appName = UUID().uuidString
            FirebaseApp.configure(name: appName, options: options)
            app = FirebaseApp.app(name: appName)
        }
        
        guard let firebaseApp = app else {
            fatalError("Can't configure Firebase")
        }

        database = Firestore.firestore(app: firebaseApp)
    }

    override public func users(userIds: [EntityIdentifier], completion: @escaping (Result<[User], ChatError>) -> Void) {
        // get unique ids
        let userIdsSet = Set(userIds)

        // compare to current set
        if userIdsSet.isSubset(of: currentUserIds) {
            let subsetUsers = users.filter { userIdsSet.contains($0.id) }
            completion(.success(subsetUsers))
        } else {
            // reset
            currentUserIds = userIdsSet
            listener?.remove()

            let query = database.collection(usersPath).whereField(FieldPath.documentID(), in: userIds)
            listener = query.addSnapshotListener(includeMetadataChanges: false) { [weak self, decoder] (snapshot, error) in
                if let snapshot = snapshot {
                    let list: [User] = snapshot.documents.compactMap {
                        do {
                            return try $0.decode(to: User.self, with: decoder)
                        } catch {
                            print("Couldn't decode document:", error)
                            return nil
                        }
                    }
                    self?.users = list
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
