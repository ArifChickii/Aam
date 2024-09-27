//
//  LoaderManager.swift
//  AAM
//
//  Created by Arif on 27/09/2024.
//

import Foundation
import UIKit

class LoaderManager {
    
    static let shared = LoaderManager()

    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let loadingView = UIView()
    private let messageLabel = UILabel()

    private init() {
        // Configure the loading view to look like an alert
        loadingView.backgroundColor = UIColor.white // Solid white background
        loadingView.layer.cornerRadius = 10
        loadingView.clipsToBounds = true
        
        // Set the loading view size
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Configure the activity indicator
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(activityIndicator)
        
        // Configure the message label
        messageLabel.textColor = .black // Text color
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0 // Allow multiple lines
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        loadingView.addSubview(messageLabel)

        // Set up constraints for the loading view
        NSLayoutConstraint.activate([
            loadingView.widthAnchor.constraint(equalToConstant: 250), // Fixed width
            loadingView.heightAnchor.constraint(greaterThanOrEqualToConstant: 100) // Minimum height
        ])
        
        // Set up constraints for the activity indicator
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            activityIndicator.topAnchor.constraint(equalTo: loadingView.topAnchor, constant: 20)
        ])
        
        // Set up constraints for the message label
        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
            messageLabel.topAnchor.constraint(equalTo: activityIndicator.bottomAnchor, constant: 20),
            messageLabel.leadingAnchor.constraint(equalTo: loadingView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: loadingView.trailingAnchor, constant: -20),
            messageLabel.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor, constant: -20) // Add bottom constraint
        ])
    }

    // Show loader and optional message, disable user interaction
    func showLoader(on view: UIView, message: String? = nil) {
        DispatchQueue.main.async {
            // Create a dimmed background view
            let backgroundView = UIView(frame: view.bounds)
            backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5) // Dimmed background
            backgroundView.tag = 999 // Assign a tag to identify it later
            view.addSubview(backgroundView)

            // Add loading view to the center of the background view
            backgroundView.addSubview(self.loadingView)

            // Center the loading view in the background view
            self.loadingView.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor).isActive = true
            self.loadingView.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor).isActive = true
            
            self.activityIndicator.startAnimating()
            self.messageLabel.text = message // Set the message
            self.messageLabel.isHidden = message == nil // Hide label if no message
            view.isUserInteractionEnabled = false  // Disable user interaction
        }
    }

    // Hide loader and re-enable user interaction
    func hideLoader() {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            // Remove loading view and background view
            if let superview = self.loadingView.superview {
                self.loadingView.removeFromSuperview()
                superview.removeFromSuperview() // Remove the dimmed background
                if let mainView = superview.superview {
                    mainView.isUserInteractionEnabled = true  // Re-enable interaction
                }
            }
        }
    }
}
