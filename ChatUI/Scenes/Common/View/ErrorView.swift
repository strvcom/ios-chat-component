//
//  ErrorView.swift
//  ChatUI
//
//  Created by Daniel Pecher on 21/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class ErrorView: UIView {
    private lazy var label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    init(message: String) {
        super.init(frame: .zero)
        
        label.text = message
        addSubview(label)
        label.pinToSuperview()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
