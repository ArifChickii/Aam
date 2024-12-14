//
//  ProductAddToBagTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductAddToBagTblCell: UITableViewCell {
    static let identifier = "ProductAddToBagTblCell"
    @IBOutlet weak var btnAddToBag: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
    
    
    
    
    /// Updates the 'Add to Bag' button based on whether the product is in the bag
    /// - Parameter isInBag: Bool indicating if the product is in the bag
    func updateAddToBagButton(isInBag: Bool) {
        
        if isInBag {
            btnAddToBag.isEnabled = false
            btnAddToBag.backgroundColor = UIColor.lightGray
            btnAddToBag.setTitle("Added to Bag", for: .normal)
            btnAddToBag.setTitleColor(.white, for: .disabled) 
        } else {
            btnAddToBag.isEnabled = true
            btnAddToBag.backgroundColor = ColorConstants.mainThemeColor
            btnAddToBag.setTitle("+ Add to Bag", for: .normal)
            btnAddToBag.setTitleColor(.white, for: .normal)
            
        }
        
    }
}
