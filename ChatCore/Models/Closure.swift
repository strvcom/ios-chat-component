//
//  Closure.swift
//  ChatCore
//
//  Created by Tomas Cejka on 2/27/20.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import Foundation

// MARK: - Typealiases for common closures
public typealias EmptyClosure = () -> Void
public typealias VoidClosure<T> = (T) -> Void
public typealias Closure<T, U> = (T) -> U
