//
//  ConversationsListCell.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit


class ConversationsListCell: UITableViewCell, ReusableCell {

    private enum Constants {
        static let imageSize = CGSize(width: 53, height: 53)
        static let borderColor = UIColor.white.cgColor
        static let borderWidth = CGFloat(2)
        static let newMessageAlertColor = UIColor(r: 254, g: 129, b: 46)
        static let messagePreviewColor = UIColor(r: 154, g: 139, b: 136)
        static let separatorColor = UIColor(r: 87, g: 61, b: 57, a: 0.1)
        static let unfilledCircleColor = UIColor(r: 229, g: 227, b: 226)
    }
    
    static let reuseIdentifier = "ConversationsListCell"
    
    @IBOutlet private var nameLabel: UILabel!
    
    @IBOutlet private var avatarImageWrapper: UIView! {
        didSet {
            avatarImageWrapper.layer.cornerRadius = (Constants.imageSize.width + (avatarImageWrapper.frame.size.width - Constants.imageSize.width)) / 2
            avatarImageWrapper.backgroundColor = Constants.unfilledCircleColor
        }
    }
    
    @IBOutlet private var avatarImage: UIImageView! {
        didSet {
            avatarImage.layer.cornerRadius = Constants.imageSize.width / 2
            avatarImage.layer.borderColor = Constants.borderColor
            avatarImage.layer.borderWidth = Constants.borderWidth
        }
    }
    
    @IBOutlet private var messagePreviewLabel: UILabel!
    
    @IBOutlet private var separator: UIView! {
        didSet {
            separator.backgroundColor = Constants.separatorColor
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
        
        nameLabel.attributedText = NSAttributedString(string: model.title, attributes: [
            .font: chatUIFontConfig.fontFor(.conversationListName)
        ])
        
        switch model.messagePreview {
        case .message(let message):
            messagePreviewLabel.attributedText = NSAttributedString(string: message, attributes: [
                .font: chatUIFontConfig.fontFor(.conversationPreview),
                .foregroundColor: Constants.messagePreviewColor
            ])
        case .newConversation:
            messagePreviewLabel.attributedText = NSAttributedString(string: "Wants to chat! 💬", attributes: [
                .font: chatUIFontConfig.fontFor(.newConversationAlert),
                .foregroundColor: Constants.newMessageAlertColor
            ])
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
