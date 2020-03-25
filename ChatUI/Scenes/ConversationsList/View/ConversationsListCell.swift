//
//  ConversationsListCell.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class ConversationsListCell: UITableViewCell {

    private enum Constants {
        static let borderWidth = CGFloat(2)
    }
    
    @IBOutlet private var nameLabel: UILabel! {
        didSet {
            nameLabel.font = .conversationListTitle
        }
    }
    
    @IBOutlet private var progressAvatar: ProgressAvatar!
    
    @IBOutlet private var messagePreviewLabel: UILabel! {
        didSet {
            messagePreviewLabel.font = .conversationListSubtitle
        }
    }
    
    @IBOutlet private var separator: UIView! {
        didSet {
            separator.backgroundColor = .conversationsCellSeparator
        }
    }
    
    var model: ConversationsListCellViewModel? {
        didSet {
            updateUI()
        }
    }
}

// MARK: Helper methods
private extension ConversationsListCell {
    func updateUI() {
        guard let model = model else {
            return
        }
        
        nameLabel.text = model.title
        
        switch model.messagePreview {
        case .message(let message):
            messagePreviewLabel.text = message
            messagePreviewLabel.font = .conversationListSubtitle
            messagePreviewLabel.textColor = .conversationsSubtitle
        case .newConversation:
            messagePreviewLabel.text = .newConversation
            messagePreviewLabel.font = .conversationListSubtitleSecondary
            messagePreviewLabel.textColor = .conversationsSubtitleAlert
        case .other:
            messagePreviewLabel.text = ""
        }
        
        progressAvatar.update(
            percentage: model.compatibility,
            imageUrl: model.avatarUrl,
            circleColor: model.circleColor
        )
        
        selectionStyle = .none
    }
}
