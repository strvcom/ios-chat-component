//
//  EmptyMessagesList.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class EmptyMessagesList: UIView {
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    var subtitle: String = "" {
        didSet {
            subtitleLabel.text = subtitle
        }
    }
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .conversationDetailEmptyTitle
            titleLabel.textColor = .conversationDetailEmptyTitle
        }
    }
    
    @IBOutlet private var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = .conversationDetailEmptySubtitle
            subtitleLabel.textColor = .conversationDetailEmptySubtitle
        }
    }
}
