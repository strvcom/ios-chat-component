//
//  UIView+Fill.swift
//  ChatApp
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIView {
    
    func pinToSuperview(edges: UIRectEdge = .all, padding: UIEdgeInsets = .zero) {
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let superview = superview else {
            return
        }
        
        if edges.contains(.top) {
            superview.addConstraint(topAnchor.constraint(equalTo: superview.topAnchor, constant: padding.top))
        }
        
        if edges.contains(.right) {
            superview.addConstraint(rightAnchor.constraint(equalTo: superview.rightAnchor, constant: -padding.right))
        }
        
        if edges.contains(.bottom) {
            superview.addConstraint(bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -padding.bottom))
        }
        
        if edges.contains(.left) {
            superview.addConstraint(leftAnchor.constraint(equalTo: superview.leftAnchor, constant: padding.left))
        }
    }
    
    func centerInSuperview(axis: Axis = .all) {
        translatesAutoresizingMaskIntoConstraints = false
        
        guard let superview = superview else {
            return
        }
        
        if axis.contains(.horizontal) {
            superview.addConstraint(centerXAnchor.constraint(equalTo: superview.centerXAnchor))
        }
        
        if axis.contains(.vertical) {
            superview.addConstraint(centerYAnchor.constraint(equalTo: superview.centerYAnchor))
        }
    }
    
}
