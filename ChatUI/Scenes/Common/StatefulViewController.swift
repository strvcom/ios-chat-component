//
//  StatefulViewController.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

indirect enum ViewControllerState {
    case loading(previous: ViewControllerState?)
    case empty(previous: ViewControllerState?)
    case loaded(previous: ViewControllerState?)
    case error(previous: ViewControllerState?, error: Error?)
}

protocol StatefulViewController where Self: UIViewController {
    var state: ViewControllerState? { get set }

    func viewForState(_ state: ViewControllerState) -> UIView
    func setState(_ state: ViewControllerState)
}

extension StatefulViewController {
    func setState(_ state: ViewControllerState) {
        let stateView = viewForState(state)
        
        view.addSubview(stateView)
        
        stateView.pinToSuperview()

        switch state {
        case let .loaded(previous), let .loading(previous), let .empty(previous), let .error(previous, _):
            if let previousState = previous {
                viewForState(previousState).removeFromSuperview()
            }
        }
        
        self.state = state
    }
}
