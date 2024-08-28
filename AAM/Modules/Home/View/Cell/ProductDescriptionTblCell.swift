//
//  ProductDescriptionTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductDescriptionTblCell: UITableViewCell {
    static let identifier = "ProductDescriptionTblCell"
    @IBOutlet weak var lblDesc: UILabel!
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
        self.lblDesc.text = obj.description ?? ""
        
        
    }
    
}
