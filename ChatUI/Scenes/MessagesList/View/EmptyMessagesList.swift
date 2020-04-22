//
//  EmptyMessagesList.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

struct EmptyMessagesListViewModel {
    let title: String
    let subtitle: String
}

class EmptyMessagesList: UIView {
    
    private let titleLineHeight: CGFloat = 32
    
    private lazy var titleParagraphStyle: NSMutableParagraphStyle = {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.maximumLineHeight = titleLineHeight
        paragraphStyle.alignment = .center
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        return paragraphStyle
    }()
    
    @IBOutlet private var titleLabel: UILabel!
    
    @IBOutlet private var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = .conversationDetailEmptySubtitle
            subtitleLabel.textColor = .conversationDetailEmptySubtitle
        }
    }
    
    func configure(with viewModel: EmptyMessagesListViewModel) {
        titleLabel.attributedText = NSAttributedString(
            string: viewModel.title,
            attributes: [
                .paragraphStyle: titleParagraphStyle,
                .font: UIFont.conversationDetailEmptyTitle,
                .foregroundColor: UIColor.conversationDetailEmptyTitle
            ]
        )
        
        subtitleLabel.text = viewModel.subtitle
    }
}
