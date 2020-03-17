//
//  UITableViewCell+Dequeue.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

extension UITableView {
    func dequeueCell<T: ReusableCell>(cellType: T.Type, for indexPath: IndexPath) -> T {
        
        guard let cell = dequeueReusableCell(withIdentifier: cellType.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Couldn't dequeue cell \(T.self)")
        }
        
        return cell
    }
}
