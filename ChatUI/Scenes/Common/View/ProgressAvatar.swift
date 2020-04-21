//
//  ProgressAvatar.swift
//  ChatUI
//
//  Created by Daniel Pecher on 24/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class ProgressAvatar: UIView {
    
    private var imagePadding: CGFloat {
        borderWidth + 1
    }
    
    private var borderWidth: CGFloat = 2
    
    private var lineSublayer: CAShapeLayer?
    
    private lazy var avatarImageView = UIImageView()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width / 2
        
        avatarImageView.layer.cornerRadius = (frame.width - imagePadding * 2) / 2
        avatarImageView.layer.borderColor = UIColor.conversationsListAvatarInnerBorder.cgColor
        avatarImageView.layer.borderWidth = borderWidth
    }
    
    func update(percentage: CGFloat, imageUrl: URL?, circleColor: UIColor) {
        lineSublayer?.removeFromSuperlayer()

        lineSublayer = circle(
            fillPercentage: percentage,
            inside: frame,
            color: circleColor,
            width: borderWidth
        )
        
        if let lineSublayer = lineSublayer {
            layer.addSublayer(lineSublayer)
        }
        
        if let imageUrl = imageUrl {
            avatarImageView.setImage(with: imageUrl)
        } else {
            avatarImageView.image = nil
        }
    }
    
    init(borderWidth: CGFloat = 3) {
        self.borderWidth = borderWidth
        
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
}

private extension ProgressAvatar {
    func setupUI() {
        addSubview(avatarImageView)
        
        avatarImageView.pinToSuperview(
            padding: UIEdgeInsets(top: imagePadding, left: imagePadding, bottom: imagePadding, right: imagePadding)
        )
        
        avatarImageView.clipsToBounds = true
        
        clipsToBounds = true
        backgroundColor = .conversationsCircleBackground
    }
    
    func circle(fillPercentage: CGFloat, inside frame: CGRect, color: UIColor, width: CGFloat = 3) -> CAShapeLayer {
        
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
        circleLayer.strokeEnd = fillPercentage
        circleLayer.lineCap = .round
        
        return circleLayer
    }
}
