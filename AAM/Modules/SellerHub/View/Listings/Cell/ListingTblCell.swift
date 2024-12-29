//
//  ListingTblCell.swift
//  AAM
//
//  Created by Arif on 26/12/2024.
//



import UIKit
import SDWebImage

class ListingTblCell: UITableViewCell {
    
    static let identifier = "ListingTblCell"
    
    // MARK: - Outlets
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblUPloadedDate: UILabel!
    @IBOutlet weak var btnEdit: UIButton!
    
    // MARK: - Properties
    private var currentProduct: ProductInfo?
    var onEditTapped: ((ProductInfo) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        // For Jost fonts (if desired)
        lblTitle.font          = UIFont(name: "Jost-SemiBold", size: 14)
        lblUPloadedDate.font   = UIFont(name: "Jost-Regular", size: 12)
        btnEdit.titleLabel?.font  = UIFont(name: "Jost-SemiBold", size: 12)
        
        // Customize btnEdit as needed, e.g.:
        // btnEdit.setTitle("Edit", for: .normal)
        
        // Add target for edit button
        btnEdit.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    func configure(with product: ProductInfo) {
        currentProduct = product
        
        // Title
        lblTitle.text = product.title
        
        // If createdDate is a string, parse it to a Date
        if let dateStr = product.createdAt,
           let actualDate = parseDateString(dateStr) {
            lblUPloadedDate.text = "Save on: \(formatDate(actualDate))"
        } else {
            lblUPloadedDate.text = "Save on: --"
        }
        
        // Load the product image
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

    // MARK: - Date parsing helpers
    /// Converts the date string from Firestore/your backend into a Date object.
    private func parseDateString(_ dateStr: String) -> Date? {
        let formatter = DateFormatter()
        // Example format: "yyyy-MM-dd'T'HH:mm:ssZ"
        // (adjust this to match your actual date string format)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        return formatter.date(from: dateStr)
    }

    /// Reformats the Date into something like "Dec 29,2024"
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd,yyyy" // e.g., "Dec 29,2024"
        return formatter.string(from: date)
    }

    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        if let product = currentProduct {
            onEditTapped?(product)
        }
    }
    

}

