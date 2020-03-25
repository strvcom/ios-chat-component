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
    private let database: Firestore

    var userId: String? {
        auth.currentUser?.providerID
    }

    private var loginCompletion: ((Result<FirebaseAuth.User, Error>) -> Void)?

    init(configUrl: String) {
        guard let options = FirebaseOptions(contentsOfFile: configUrl) else {
            fatalError("Can't configure Firebase")
        }
        FirebaseApp.configure(options: options)
        self.database = Firestore.firestore()
    }
}

// MARK: - Login view controller
extension FirebaseAuthentication {
    func authenticationViewController(loginCompletion: @escaping (Result<FirebaseAuth.User, Error>) -> Void) -> UIViewController {
        self.loginCompletion = loginCompletion
        let authUI = FUIAuth.defaultAuthUI()!
        authUI.delegate = self
        authUI.providers = [FUIGoogleAuth(), FUIEmailAuth()]
        let authenticationViewController = authUI.authViewController()
        return authenticationViewController
    }
}

// MARK: - Store user
private extension FirebaseAuthentication {
    func storeUser(user: FirebaseAuth.User) {
        let reference = self.database.collection("users").document(user.uid)
        var userJson: [String: Any] = ["id": user.uid]
        if let photoUrl = user.photoURL {
            userJson["imageUrl"] = photoUrl
        }
        if let displayName = user.displayName {
            userJson["name"] = displayName
        }
        if let email = user.email {
            userJson["email"] = email
        }
        reference.setData(userJson)
    }
}

// MARK: - FUIAuthDelegate
extension FirebaseAuthentication: FUIAuthDelegate {
    func authUI(_ authUI: FUIAuth, didSignInWith user: FirebaseAuth.User?, error: Error?) {
        if let user = user {
            // store user into users
            storeUser(user: user)
            loginCompletion?(.success(user))
        } else if let error = error {
            loginCompletion?(.failure(error))
        }
    }
}
