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
        static let imageSize = CGSize(width: 53, height: 53)
        static let borderWidth = CGFloat(2)
    }
    
    @IBOutlet private var nameLabel: UILabel! {
        didSet {
            nameLabel.font = .conversationListTitle
        }
    }
    
    @IBOutlet private var avatarImageWrapper: UIView! {
        didSet {
            avatarImageWrapper.layer.cornerRadius = (Constants.imageSize.width + (avatarImageWrapper.frame.size.width - Constants.imageSize.width)) / 2
            avatarImageWrapper.backgroundColor = .conversationsCircleBackground
        }
    }
    
    @IBOutlet private var avatarImage: UIImageView! {
        didSet {
            avatarImage.layer.cornerRadius = Constants.imageSize.width / 2
            avatarImage.layer.borderColor = UIColor.conversationsListAvatarInnerBorder.cgColor
            avatarImage.layer.borderWidth = Constants.borderWidth
        }
    }
    
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
    
    private var lineSublayer: CAShapeLayer?
    
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
        
        lineSublayer?.removeFromSuperlayer()
        
        lineSublayer = circle(
            forCompatibility: model.compatibility,
            inside: avatarImageWrapper.frame,
            color: model.circleColor
        )
        
        if let lineSublayer = lineSublayer {
            avatarImageWrapper.layer.addSublayer(lineSublayer)
        }
        
        if let imageUrl = model.avatarUrl {
            avatarImage.setImage(with: imageUrl)
        } else {
            avatarImage.image = nil
        }
        
        selectionStyle = .none
    }
    
    func circle(forCompatibility compatibility: CGFloat, inside frame: CGRect, color: UIColor, width: CGFloat = 3) -> CAShapeLayer {
        
        let line = UIBezierPath(
            arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
            radius: (frame.size.width - width) / 2,
            startAngle: CGFloat(-90 * Double.pi/180),
            endAngle: CGFloat(270 * Double.pi/180),
            clockwise: true
        )
        
        let circleLayer = CAShapeLayer()
        circleLayer.path = line.cgPath
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.strokeColor = color.cgColor
        circleLayer.lineWidth = width
        circleLayer.strokeEnd = compatibility
        circleLayer.lineCap = .round
        
        return circleLayer
    }
}
