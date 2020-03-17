//
//  UIColor+RGB.swift
//  ChatApp
//
//  Created by Daniel Pecher on 17/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public extension UIColor {
    // swiftlint:disable:next identifier_name
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat = 1.0) {
        self.init(red: r / 255, green: g / 255, blue: b / 255, alpha: a)
    }
}
