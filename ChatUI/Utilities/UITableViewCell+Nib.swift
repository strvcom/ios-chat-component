//
//  UITableViewCell+Nib.swift
//  ChatUI
//
//  Created by Daniel Pecher on 23/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UITableViewCell {
    static var nibIdentifier: String {
        String(describing: Self.self)
    }
    
    static var nib: UINib {
        return UINib(nibName: nibIdentifier, bundle: Bundle(for: Self.self))
    }
}
