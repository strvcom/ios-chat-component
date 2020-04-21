//
//  StatefulViewController.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

indirect enum ControllerState {
    case loading(previous: ControllerState?)
    case empty(previous: ControllerState?)
    case loaded(previous: ControllerState?)
    case error(previous: ControllerState?, error: Error?)
}

protocol StatefulViewController where Self: UIViewController {
    var state: ControllerState? { get set }

    func viewForState(_ state: ControllerState) -> UIView
    func setState(_ state: ControllerState)
}

extension StatefulViewController {
    func setState(_ state: ControllerState) {
        let stateView = viewForState(state)
        
        view.addSubview(stateView)
        
        stateView.centerInSuperview()

        switch state {
        case let .loaded(previous), let .loading(previous), let .empty(previous), let .error(previous, _):
            if let previousState = previous {
                viewForState(previousState).removeFromSuperview()
            }
        }
        
        self.state = state
    }
}
