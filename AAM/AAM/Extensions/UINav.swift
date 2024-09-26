//
//  Storyboard.swift
//  iOSTask
//
//  Created by Arif ww on 12/07/2024.
//


import Foundation
import UIKit

extension UINavigationController {

    func removeViewController(_ controller: UIViewController.Type) {
        if let viewController = viewControllers.first(where: { $0.isKind(of: controller.self) }) {
            viewController.removeFromParent()
        }
    }
}
