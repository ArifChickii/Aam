//
//  SellerHubItemsTblCell.swift
//  AAM
//
//  Created by Arif on 25/12/2024.
//

import UIKit

class SellerHubItemsTblCell: UITableViewCell {
    static let identifier = "SellerHubItemsTblCell"
    // MARK: - Outlets
    @IBOutlet weak var imgIcon: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDescription: UILabel!
    
    // Ensure these outlets are connected in your storyboard or XIB

    override func awakeFromNib() {
        super.awakeFromNib()
        setupFonts()
    }

    func configure(with itemData: SellerHubItemData) {
        lblTitle.text       = itemData.title
        lblDescription.text = itemData.description
        imgIcon.image       = UIImage(named: itemData.imageName)
    }
    
    private func setupFonts() {
        lblTitle.font       = UIFont(name: "Jost Medium", size: 14)
        lblDescription.font = UIFont(name: "Jost Regular", size: 14)
    }
}

