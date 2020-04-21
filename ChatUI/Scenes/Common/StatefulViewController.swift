//
//  StatefulViewController.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

enum ViewControllerState {
    case loading
    case empty
    case loaded
    case error(error: Error?)
}

protocol StatefulViewController where Self: UIViewController {
    var state: ViewControllerState? { get set }
    var contentView: UIView? { get }

    func setState(_ state: ViewControllerState)
}

extension StatefulViewController {
    func setState(_ state: ViewControllerState) {
        contentView?.removeFromSuperview()

        self.state = state
        
        guard let newView = contentView else {
            return
        }
        
        view.addSubview(newView)
        newView.pinToSuperview()
    }
}
