//
//  ProductSizeTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductSizeTblCell: UITableViewCell {
    static let identifier = "ProductSizeTblCell"
    @IBOutlet weak var lblSize: UILabel!
    
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
        
        let sizeStr = obj.sizes?.joined(separator: ", ") ?? ""
        let colorStr = obj.colors?.joined(separator: ", ") ?? ""
        self.lblSize.text = "\(sizeStr ?? "")/\(colorStr ?? "")"
        
    }
    
}
