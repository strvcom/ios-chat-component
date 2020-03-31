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
    
    @IBOutlet private var iconImage: UIImageView! {
        didSet {
            iconImage.image = .conversationsListEmptyIcon
        }
    }
    
    @IBOutlet private var titleLabel: UILabel! {
        didSet {
            titleLabel.font = .conversationsListEmptyTitle
            titleLabel.textColor = .conversationsEmptyTitle
            titleLabel.text = .conversationsListEmptyTitle
        }
    }
    
    @IBOutlet private var subtitleLabel: UILabel! {
        didSet {
            subtitleLabel.font = .conversationsListEmptySubtitle
            subtitleLabel.textColor = .conversationsEmptySubtitle
            subtitleLabel.text = .conversationsListEmptySubtitle
        }
   }
    
    @IBOutlet private var actionButton: UIButton! {
        didSet {
            actionButton.setTitle(.conversationsListEmptyActionTitle, for: .normal)
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
