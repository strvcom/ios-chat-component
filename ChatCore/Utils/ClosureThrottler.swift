//
//  ClosureThrottler.swift
//  ChatCore
//
//  Created by Tomas Cejka on 3/23/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: Solve closure throttle
final class ListenerThrottler<MessageUI, MessagesResult> {
    let closure: (DataPayload<[MessageUI]>, [IdentifiableClosure<MessagesResult, Void>]) -> Void

    private var workItems: [Listener: DispatchWorkItem] = [:]

    init(closure: @escaping (DataPayload<[MessageUI]>, [IdentifiableClosure<MessagesResult, Void>]) -> Void) {
        self.closure = closure
    }
}

// MARK: - Handling delay & cancel logic
extension ListenerThrottler {
    func handleClosures(interval: TimeInterval = 0.0, payload: DataPayload<[MessageUI]>, listener: Listener, closures: [IdentifiableClosure<MessagesResult, Void>]) {

        workItems[listener]?.cancel()
        workItems.removeValue(forKey: listener)

        let workItem = DispatchWorkItem { [weak self] in
            self?.closure(payload, closures)
        }
        workItems[listener] = workItem

        DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem)
    }
}
