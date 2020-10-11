//
//  AppDependency.swift
//
//
//  Created by Jan on 16/04/2020.
//

import Foundation
import Chat
import Firebase

struct AppDependency {
    let chat: ChatService
    let firebaseAuthentication: FirebaseAuthentication
}
