//
//  NavigationTitle.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit
import ChatCore

class ConversationDetailNavigationTitle: UIView {
    
    // MARK: Views
    private lazy var avatar: ProgressAvatar = {
        ProgressAvatar(borderWidth: 1)
    }()
    
    private lazy var title: UILabel = {
        let title = UILabel()
        
        title.text = user.name
        title.font = .navigationTitle
        title.textColor = .navigationTitle
        
        return title
    }()
    
    // MARK: Constants
    private let avatarSize = CGSize(width: 24, height: 24)
    private let avatarTitleSpacing: CGFloat = 8
    
    // MARK: Properties
    private var user: UserRepresenting
    
    init(user: UserRepresenting) {
        self.user = user
        
        super.init(frame: .zero)
        
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Setup
private extension ConversationDetailNavigationTitle {
    func setup() {
        addSubview(avatar)
        
        avatar.pinToSuperview(edges: [.left, .top, .bottom], padding: .zero)
        avatar.setSize(width: avatarSize.width, height: avatarSize.height)

        addSubview(title)
        title.pinToSuperview(edges: [.top, .right, .bottom], padding: .zero)
        title.next(to: avatar, spacing: avatarTitleSpacing)
    }
}
