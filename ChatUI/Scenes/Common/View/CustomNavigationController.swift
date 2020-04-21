//
//  CustomNavigationController.swift
//  ChatUI
//
//  Created by Daniel Pecher on 20/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.barTintColor = .navigationBarTintColor
        navigationBar.shadowImage = UIImage()
        navigationBar.backIndicatorImage = UIImage()
        navigationBar.backIndicatorTransitionMaskImage = UIImage()
    }
}
