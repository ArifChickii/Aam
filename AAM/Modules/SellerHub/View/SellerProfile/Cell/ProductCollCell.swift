//
//  ProductCollCell.swift
//  AAM
//
//  Created by Arif on 26/12/2024.
//

import UIKit

class ProductCollCell: UICollectionViewCell {
    static let identifier = "ProductCollCell"
    
    @IBOutlet weak var productImageView: UIImageView!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    /// Basic in-memory image cache
    private static let imageCache = NSCache<NSURL, UIImage>()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Set fonts
        priceLabel.font = UIFont(name: "Jost-SemiBold", size: 14)
        titleLabel.font = UIFont(name: "Jost-Regular", size: 14)
        
        // Optional placeholder image
        productImageView.image = UIImage(named: "dummy")
        // Make sure you have a "Placeholder" image in your assets
        // or use a system icon: UIImage(systemName: "photo")
    }
    
    /// Configure cell
    func configure(product: ProductInfo) {
        // Update title and price labels
        titleLabel.text = product.title
        priceLabel.text = "$\(product.price ?? "0")"
        
        // Load the product image using SDWebImage
        if let firstImageURLString = product.images?.first,
           let imageURL = URL(string: firstImageURLString) {
            // Set a placeholder image while the main image loads
            productImageView.sd_setImage(with: imageURL,
                                         placeholderImage: UIImage(named: "Placeholder"),
                                         options: [.scaleDownLargeImages, .continueInBackground],
                                         completed: nil)
        } else {
            // If no image URL, show a placeholder
            productImageView.image = UIImage(named: "Placeholder")
        }
    }
    
    
}


