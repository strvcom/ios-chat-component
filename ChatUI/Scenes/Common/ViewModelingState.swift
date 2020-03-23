//
//  ViewModelingState.swift
//  ChatUI
//
//  Created by Daniel Pecher on 16/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

public enum ViewModelingState<T> {
    case initial
    case loading
    case ready(value: T)
    case failed(error: Error)
}
