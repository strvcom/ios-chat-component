//
//  ReachabilityObserver.swift
//  ChatApp
//
//  Created by Tomas Cejka on 2/26/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Wrap reachability states into enum
enum ReachableState {
    case reachable
    case unreachable
}

// MARK: - Helper reachability observer
final class ReachabilityObserver {
    private var reachability: Reachability?
    private var reachabilityChanged: VoidClosure<ReachableState>

    deinit {
        print("ReachabilityObserver deinit")
        stopReachabilityObserving()
    }

    init(reachabilityChanged: @escaping VoidClosure<ReachableState>) {
        self.reachabilityChanged = reachabilityChanged
        startReachabilityObserving()
    }
}

// MARK: - Observer flow, observe rechability notifications and clean up
private extension ReachabilityObserver {
    // Observe reachability changes
    func startReachabilityObserving() {
        do {
            reachability = try Reachability()

            reachability?.whenReachable = { [weak self] reachability in
                self?.reachabilityChanged(.reachable)
            }

            reachability?.whenUnreachable = { [weak self] reachability in
                self?.reachabilityChanged(.unreachable)
            }

            try reachability?.startNotifier()
        } catch {
            print("Reachability throws \(error.localizedDescription)")
        }
    }

    // Clean up
    func stopReachabilityObserving() {
        reachability?.stopNotifier()
        reachability = nil
    }
}
