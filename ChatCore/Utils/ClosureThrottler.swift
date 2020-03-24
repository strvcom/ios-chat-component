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

    private var workItem: DispatchWorkItem?

    init(closure: @escaping (DataPayload<[MessageUI]>, [IdentifiableClosure<MessagesResult, Void>]) -> Void) {
        self.closure = closure
    }
}

// MARK: - Handling delay & cancel logic
extension ListenerThrottler {
    func handleClosures(interval: TimeInterval = 0.0, payload: DataPayload<[MessageUI]>, closures: [IdentifiableClosure<MessagesResult, Void>]) {
        workItem?.cancel()

        workItem = DispatchWorkItem { [weak self] in
            self?.closure(payload, closures)
        }

        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + interval, execute: workItem)
        }
    }
}
