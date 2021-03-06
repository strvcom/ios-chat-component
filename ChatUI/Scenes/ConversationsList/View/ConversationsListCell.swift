//
//  ConversationsListCell.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class ConversationsListCell: UITableViewCell {
    
    @IBOutlet private var nameLabel: UILabel! {
        didSet {
            nameLabel.font = .conversationsListTitle
        }
    }
    
    @IBOutlet private var avatarView: AvatarView!
    
    @IBOutlet private var messagePreviewLabel: UILabel! {
        didSet {
            messagePreviewLabel.font = .conversationsListSubtitle
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
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        selectionStyle = .none
    }
}

// MARK: Helper methods
private extension ConversationsListCell {
    func updateUI() {
        guard let model = model else {
            return
        }
        
        nameLabel.text = model.title
        avatarView.configure(with: model.avatarURL)
        
        switch model.messagePreview {
        case .message(let message):
            messagePreviewLabel.text = message
            messagePreviewLabel.font = .conversationsListSubtitle
            messagePreviewLabel.textColor = .conversationsSubtitle
        case .newConversation:
            messagePreviewLabel.text = .newConversation
            messagePreviewLabel.font = .conversationsListSubtitleSecondary
            messagePreviewLabel.textColor = .conversationsSubtitleAlert
        case .other:
            messagePreviewLabel.text = ""
        }
    }
}
