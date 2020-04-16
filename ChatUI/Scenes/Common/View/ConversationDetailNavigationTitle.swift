//
//  NavigationTitle.swift
//  ChatUI
//
//  Created by Daniel Pecher on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class ConversationDetailNavigationTitle: UIView {
    
    // MARK: Views
    private lazy var avatar: ProgressAvatar = {
        ProgressAvatar(borderWidth: 1)
    }()
    
    private lazy var title: UILabel = {
        let title = UILabel()
        
        title.text = user.displayName
        title.font = .navigationTitle
        title.textColor = .navigationTitle
        
        return title
    }()
    
    // MARK: Constants
    private let avatarSize = CGSize(width: 24, height: 24)
    private let avatarTitleSpacing: CGFloat = 8
    
    // MARK: Properties
    private var user: User
    
    init(user: User) {
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
        avatar.addConstraints([
            avatar.heightAnchor.constraint(equalToConstant: avatarSize.height),
            avatar.widthAnchor.constraint(equalToConstant: avatarSize.width)
        ])
        
        avatar.update(
            percentage: CGFloat(user.compatibility ?? 0),
            imageUrl: user.imageUrl,
            circleColor: .conversationsCircleDefault
        )

        addSubview(title)
        title.pinToSuperview(edges: [.top, .right, .bottom], padding: .zero)
        addConstraint(title.leadingAnchor.constraint(equalTo: avatar.trailingAnchor, constant: avatarTitleSpacing))
    }
}
