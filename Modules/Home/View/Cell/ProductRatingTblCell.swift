//
//  ProductRatingTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductRatingTblCell: UITableViewCell {
    static let identifier = "ProductRatingTblCell"
    @IBOutlet weak var lblRating: UILabel!
    @IBOutlet weak var lblReviewerName: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(obj: Product){
        self.lblRating.text = "(\(obj.rating ?? ""))"
        self.lblRating.text = "Aam Reviewer"
        
        
    }
    
}
