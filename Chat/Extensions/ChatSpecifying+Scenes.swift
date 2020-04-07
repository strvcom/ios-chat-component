//
//  ChatSpecifying+Scenes.swift
//  Chat
//
//  Created by Jan on 07/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

@available(iOS 13.0, *)
public extension ChatSpecifying {
    func interface(for scene: UIScene) -> Interface {
        return interface(with: ObjectIdentifier(scene))
    }
}
