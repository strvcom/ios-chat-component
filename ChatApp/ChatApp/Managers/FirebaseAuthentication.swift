//
//  FirebaseAuthentication.swift
//  ChatApp
//
//  Created by Tomas Cejka on 3/25/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation
import FirebaseAuth
import FirebaseUI
import FirebaseFirestore

// MARK: - Simple solution for firebase authentication
final class FirebaseAuthentication: NSObject {
    private let usersPath = "users"

    private lazy var auth: Auth = Auth.auth()
    var user: User? {
        guard let firUser = auth.currentUser else {
            return nil
        }
        let user = User(id: firUser.uid, name: firUser.displayName ?? firUser.email ?? "", imageUrl: firUser.photoURL?.absoluteString)
        return user
    }

    let database: Firestore
    private var loginCompletion: ((Result<User, Error>) -> Void)?

    deinit {
        print("\(self) deinit")
    }

    init(database: Firestore) {
        self.database = database
    }
}

// MARK: - Login view controller
extension FirebaseAuthentication {
    func authenticationViewController(loginCompletion: @escaping (Result<User, Error>) -> Void) -> UIViewController {
        self.loginCompletion = loginCompletion
        guard let authUI = FUIAuth.defaultAuthUI() else {
            fatalError("Unable to create login UI")
        }
        authUI.delegate = self
        authUI.providers = [FUIGoogleAuth(), FUIEmailAuth()]
        return authUI.authViewController()
    }
}

// MARK: - Store user
private extension FirebaseAuthentication {
    func storeUser(user: User, completion: @escaping (Result<Void, Error>) -> Void) {
        let reference = database.collection(usersPath).document(user.id)
        do {
            try reference.setData(from: user) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch {
            completion(.failure(error))
        }
    }
}

// MARK: - FUIAuthDelegate
extension FirebaseAuthentication: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?) {
        if let user = self.user {
            storeUser(user: user) { [weak self] result in
                switch result {
                case .success:
                    self?.loginCompletion?(.success(user))
                case .failure(let error):
                    self?.loginCompletion?(.failure(error))
                }
            }
        } else if let error = error {
            loginCompletion?(.failure(error))
        }
    }
}
