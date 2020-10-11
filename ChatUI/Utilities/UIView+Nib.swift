//
//  UIView+Nib.swift
//  ChatUI
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UIView {
    static var nibIdentifier: String {
        String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: nibIdentifier, bundle: Bundle(for: Self.self))
    }
    
    static var nibInstance: Self {
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            fatalError("Couldn't load XIB file \(nibIdentifier)")
        }
        
        return view
    }
}
