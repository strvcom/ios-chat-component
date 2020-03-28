//
//  EmptyConversationsList.swift
//  ChatUI
//
//  Created by Daniel Pecher on 27/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class EmptyConversationsList: UIView {
    
    var buttonAction: (() -> Void)?
    
    @IBOutlet private var iconImage: UIImageView!
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .conversationListEmptyTitle
            titleLabel.textColor = .conversationsEmptyTitle
            titleLabel.text = .emptyConversationsTitle
        }
    }
    
    @IBOutlet private var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = .conversationListEmptySubtitle
            subtitleLabel.textColor = .conversationsEmptySubtitle
            subtitleLabel.text = .emptyConversationsSubtitle
        }
   }
    
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.setTitle(.takeAQuizButton, for: .normal)
            actionButton.setTitleColor(.buttonForeground, for: .normal)
            actionButton.backgroundColor = .buttonBackground
            actionButton.layer.cornerRadius = Constants.buttonCornerRadius
            actionButton.titleLabel?.font = .buttonTitle
        }
    }
    
    @IBAction private func onActionButtonTap(_ sender: UIButton) {
        buttonAction?()
    }
}
