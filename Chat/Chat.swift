//
//  Chat.swift
//  Chat
//
//  Created by Jan Schwarz on 05/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore
import ChatNetworkingFirestore
import ChatUI

public class Chat {
    public typealias Configuration = ChatNetworkingFirestoreConfig

    let interface: ChatUI<ChatCore<ChatNetworkingFirestore, ChatModelsUI>>
    let core: ChatCore<ChatNetworkingFirestore, ChatModelsUI>

    public init(config: Configuration) {
        let networking = ChatNetworkingFirestore(config: config)
        let core = ChatCore<ChatNetworkingFirestore, ChatModelsUI>(networking: networking)
        self.core = core
        self.interface = ChatUI(core: core)
    }
}

// MARK: - UI
public extension Chat {
    func conversationsList() -> UIViewController {
        let list = interface.conversationsList()
        return list
    }
}

// MARK: - Messages
public extension Chat {
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void) {
        core.runBackgroundTasks(completion: completion)
    }

    func resendUnsentMessages() {
        core.resendUnsentMessages()
    }
}

// MARK: - Users
public extension Chat {
    func setCurrentUser(userId: ObjectIdentifier, name: String) {
        let user = User(id: userId, name: name, imageUrl: nil)
        core.setCurrentUser(user: user)
    }
}
