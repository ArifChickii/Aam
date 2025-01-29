//
//  FavouritesProductsTblCell.swift
//  AAM
//
//  Created by Arif on 29/01/2025.
//

import UIKit
import SDWebImage

class FavouritesProductsTblCell: UITableViewCell {
    
    static let identifier = "FavouritesProductsTblCell"
    
    // MARK: - Outlets
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUPloadedDate: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    // MARK: - Properties
    private var currentProduct: ProductInfo?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // For Jost fonts (optional)
        lblTitle.font        = UIFont(name: "Jost-SemiBold", size: 14)
        lblUPloadedDate.font = UIFont(name: "Jost-Regular", size: 12)
        lblPrice.font        = UIFont(name: "Jost-SemiBold", size: 14)
    }

    func configure(with product: ProductInfo) {
        self.currentProduct = product
        
        // Title
        lblTitle.text = product.title
        
        // Price
        lblPrice.text = "$\(product.price ?? "0.0")"
        
        // If createdAt is a string, parse it to a Date
        if let dateStr = product.createdAt,
           let actualDate = parseDateString(dateStr) {
            lblUPloadedDate.text = "Added: \(formatDate(actualDate))"
        } else {
            lblUPloadedDate.text = "Added: --"
        }
        
        // Load the product image (firstImage)
        if let firstImageStr = product.images?.first,
           let imageURL = URL(string: firstImageStr) {
            imgProduct.sd_setImage(with: imageURL,
                                   placeholderImage: UIImage(named: "Placeholder"),
                                   options: [.scaleDownLargeImages],
                                   context: nil)
        } else {
            imgProduct.image = UIImage(named: "Placeholder")
        }
    }
    
    // MARK: - Date Helpers
    private func parseDateString(_ dateStr: String) -> Date? {
        let formatter = DateFormatter()
        // Adjust format if needed
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: dateStr)
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy" // e.g. "Dec 29, 2024"
        return formatter.string(from: date)
    }
}

