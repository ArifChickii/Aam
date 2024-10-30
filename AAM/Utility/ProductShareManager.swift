//
//  ProductShareManager.swift
//  AAM
//
//  Created by Arif on 28/10/2024.
//

import Foundation
import UIKit
import SDWebImage

class ProductShareManager {
    static let shared = ProductShareManager()
    private init() {}
    
    func shareProduct(product: ProductInfo, sender: UIButton, from viewController: UIViewController) {
        guard let images = product.images,
              !images.isEmpty,
              let imageUrl = URL(string: images[0]) else {
            print("❌ No valid image URL found")
            return
        }
        
        // Show loading indicator
        let loadingIndicator = UIActivityIndicatorView(style: .medium)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        sender.addSubview(loadingIndicator)
        NSLayoutConstraint.activate([
            loadingIndicator.centerXAnchor.constraint(equalTo: sender.centerXAnchor),
            loadingIndicator.centerYAnchor.constraint(equalTo: sender.centerYAnchor)
        ])
        loadingIndicator.startAnimating()
        
        // Download image using SDWebImage
        SDWebImageManager.shared.loadImage(
            with: imageUrl,
            options: .highPriority,
            progress: nil) { [weak self] (image, data, error, cacheType, finished, url) in
                
                DispatchQueue.main.async {
                    loadingIndicator.removeFromSuperview()
                }
                
                guard let self = self,
                      let image = image else {
                    print("❌ Failed to load image: \(error?.localizedDescription ?? "Unknown error")")
                    return
                }
                
                // Create Firebase Dynamic Link
                DynamicLinkManager.shared.createDynamicLink(for: product) { shortURL in
                    DispatchQueue.main.async {
                        guard let shortURL = shortURL else {
                            print("❌ Failed to create dynamic link")
                            return
                        }
                        
                        // Create sharing text with the link
                        let sharingText = """
                        Check out this product on AAM!
                        \(product.title ?? "Product")
                        Price: \(product.price ?? "")

                        🔗 View Product: \(shortURL.absoluteString)
                        """
                        
                        // Present share sheet
                        let activityItems: [Any] = [sharingText, image]
                        let activityVC = UIActivityViewController(
                            activityItems: activityItems,
                            applicationActivities: nil
                        )
                        
                        // For iPad: Specify the source view
                        if let popoverController = activityVC.popoverPresentationController {
                            popoverController.sourceView = sender
                            popoverController.sourceRect = sender.bounds
                        }
                        
                        viewController.present(activityVC, animated: true)
                    }
                }
            }
    }
}

