//
//  MessageSpecification.swift
//  ChatUI
//
//  Created by Mireya Orta on 1/14/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

public enum MessageSpecification: MessageSpecifying {
    case text(message: String)
    case image(image: UIImage)
}
