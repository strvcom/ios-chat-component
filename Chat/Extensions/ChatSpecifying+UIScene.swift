//
//  ChatSpecifying+UIScene.swift
//  Chat
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
public extension ChatSpecifying {
    /// Get UI instance identified by a given scene
    /// - Parameter scene: Instance of `UIScene` that requests chat UI interface
    /// - Returns: Chat UI interface
    func interface(for scene: UIScene) -> Interface {
        return interface(with: ObjectIdentifier(scene))
    }
}
