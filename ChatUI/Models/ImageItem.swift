//
//  ImageItem.swift
//  ChatUI
//
//  Created by Daniel Pecher on 28/01/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import MessageKit

struct ImageItem: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}
