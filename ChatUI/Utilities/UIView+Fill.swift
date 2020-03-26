//
//  UIView+Fill.swift
//  ChatApp
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public extension UIView {
    func fill(_ view: UIView, padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        view.addConstraints([
            topAnchor.constraint(equalTo: view.topAnchor, constant: padding.top),
            rightAnchor.constraint(equalTo: view.rightAnchor, constant: -padding.right),
            bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -padding.bottom),
            leftAnchor.constraint(equalTo: view.leftAnchor, constant: padding.left)
        ])
    }
}
