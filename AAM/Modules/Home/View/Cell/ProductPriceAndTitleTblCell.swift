//
//  ProductPriceAndTitleTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductPriceAndTitleTblCell: UITableViewCell {
    static let identifier = "ProductPriceAndTitleTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblCutPrice: UILabel!
    @IBOutlet weak var btnShare: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(obj: ProductInfo){
        self.lblTitle.text = obj.title
        self.lblPrice.text = "\(obj.price ?? "0.0" )"
        self.lblCutPrice.text = "\(obj.cutPrice ?? "0.0")"
        
    }
}
