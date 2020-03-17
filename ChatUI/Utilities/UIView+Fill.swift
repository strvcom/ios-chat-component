//
//  UIView+Fill.swift
//  ChatApp
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public extension UIView {
    func fill(_ view: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            topAnchor.constraint(equalTo: view.topAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor)
        ])
    }
}
