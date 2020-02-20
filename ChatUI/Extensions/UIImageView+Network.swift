//
//  UIImageView+Network.swift
//  ChatUI
//
//  Created by Daniel Pecher on 29/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

public extension UIImageView {
    func setImage(with url: URL) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard error == nil, let data = data else {
                return
            }
            DispatchQueue.main.async { [weak self] in
                self?.image = UIImage(data: data)
            }
        }.resume()
    }
}
