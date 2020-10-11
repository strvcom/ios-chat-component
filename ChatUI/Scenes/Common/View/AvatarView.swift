//
//  AvatarView.swift
//  ChatUI
//
//  Created by Daniel Pecher on 24/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class AvatarView: UIView {
    private lazy var imageView = UIImageView()
    
    init() {
        super.init(frame: .zero)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setupUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.cornerRadius = frame.width / 2
    }
    
    func configure(with imageUrl: URL?) {
        if let imageUrl = imageUrl {
            imageView.setImage(with: imageUrl)
        } else {
            imageView.image = nil
        }
    }
}

private extension AvatarView {
    func setupUI() {
        addSubview(imageView)
        
        imageView.pinToSuperview()
        
        clipsToBounds = true
    }
}
