//
//  UIViewcontroller.swift
//  AAM
//
//  Created by Arif on 11/11/2024.
//

import Foundation
import UIKit
extension UIViewController {
    /// Displays a toast message on the screen.
    /// - Parameters:
    ///   - message: The message to display.
    ///   - duration: How long the toast should be visible.
    func showToast(message: String, duration: Double = 2.0) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 150,
                                               y: self.view.frame.size.height - 150,
                                               width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = UIFont.systemFont(ofSize: 16.0)
        toastLabel.textAlignment = .center
        toastLabel.text = message
        toastLabel.alpha = 0.0
        toastLabel.layer.cornerRadius = 10
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 0.5, delay: 0.0,
                       options: .curveEaseIn, animations: {
            toastLabel.alpha = 1.0
        }, completion: { _ in
            UIView.animate(withDuration: 0.5, delay: duration,
                           options: .curveEaseOut, animations: {
                toastLabel.alpha = 0.0
            }, completion: { _ in
                toastLabel.removeFromSuperview()
            })
        })
    }
}





extension UIViewController {
    private static let loadingIndicatorTag = 999999  // A unique tag for the loading indicator

    /// Displays a loading indicator over the entire view controller.
    func showLoadingIndicator() {
        // Check if the loading indicator is already presented
        if let _ = self.view.viewWithTag(UIViewController.loadingIndicatorTag) {
            return
        }

        // Create a semi-transparent overlay
        let overlay = UIView(frame: self.view.bounds)
        overlay.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        overlay.tag = UIViewController.loadingIndicatorTag

        // Create and configure the activity indicator
        let activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = overlay.center
        activityIndicator.startAnimating()

        // Add the activity indicator to the overlay
        overlay.addSubview(activityIndicator)

        // Add the overlay to the view controller's view
        self.view.addSubview(overlay)
    }

    /// Hides the loading indicator.
    func hideLoadingIndicator() {
        // Find the overlay by its unique tag and remove it
        if let overlay = self.view.viewWithTag(UIViewController.loadingIndicatorTag) {
            overlay.removeFromSuperview()
        }
    }
}

