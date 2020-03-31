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
import FirebaseCore

// MARK: - Simple solution for firebase authentication
final class FirebaseAuthentication: NSObject {

    private lazy var auth: Auth = Auth.auth()
    var user: FirebaseAuth.User? {
        auth.currentUser
    }

    let database: Firestore
    private var loginCompletion: ((Result<FirebaseAuth.User, Error>) -> Void)?

    deinit {
        print("\(self) deinit")
    }

    init(database: Firestore) {
        self.database = database
    }
}

// MARK: - Login view controller
extension FirebaseAuthentication {
    func authenticationViewController(loginCompletion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) -> UIViewController {
        self.loginCompletion = loginCompletion
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        authUI.providers = [FUIGoogleAuth(), FUIEmailAuth()]
        return authUI.authViewController()
    }
}


// MARK: - Store user
private extension FirebaseAuthentication {
    func storeUser(user: FirebaseAuth.User) {
        let reference = database.collection("users").document(user.uid)
        var userJson: [String: Any] = [:]
        if let photoUrl = user.photoURL {
            userJson["imageUrl"] = photoUrl
        }

        let displayName = user.displayName ?? user.email ?? ""
        userJson["name"] = displayName

        if let email = user.email {
            userJson["email"] = email
        }
        reference.setData(userJson)
        database.terminate { [weak self] error in
            self?.loginCompletion?(.success(user))
        }
    }
}

// MARK: - FUIAuthDelegate
extension FirebaseAuthentication: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?) {
        if let user = user {
            storeUser(user: user)

        } else if let error = error {
            loginCompletion?(.failure(error))
        }
    }
}
