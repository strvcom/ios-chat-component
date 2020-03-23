//
//  UIColor+RGB.swift
//  ChatApp
//
//  Created by Daniel Pecher on 17/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255, green: CGFloat(green) / 255, blue: CGFloat(blue) / 255, alpha: alpha)
    }
}
