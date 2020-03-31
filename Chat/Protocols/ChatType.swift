//
//  ChatType.swift
//  Chat
//
//  Created by Jan on 31/03/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

protocol ChatType {
    func interface(with id: String) -> UIViewController
    func runBackgroundTasks(completion: @escaping (UIBackgroundFetchResult) -> Void)
    func resendUnsentMessages()
}
