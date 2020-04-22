//
//  AppCoordinator.swift
//  ChatApp
//
//  Created by Jan on 15/04/2020.
//  Copyright © 2020 Jan Schwarz. All rights reserved.
//

import UIKit

class AppCoordinator {
    let dependency: AppDependency
    
    private var childCoordinators: [SceneCoordinator] = []

    init(dependency: AppDependency) {
        self.dependency = dependency
    }
    
    func startScene(with window: UIWindow) -> SceneCoordinator {
        let coordinator = SceneCoordinator(parent: self, dependency: dependency, window: window)
        
        childCoordinators.append(coordinator)
        
        return coordinator
    }
    
    func disconnect(coordinator: SceneCoordinator) {
        childCoordinators = childCoordinators.filter({ ObjectIdentifier(coordinator) != ObjectIdentifier($0) })
    }
}
