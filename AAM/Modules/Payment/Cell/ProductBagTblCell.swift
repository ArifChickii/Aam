//
//  ProductBagTblCell.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class ProductBagTblCell: UITableViewCell {
    static let identifier = "ProductBagTblCell"
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblColorAndSize: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnIncrement: UIButton!
    @IBOutlet weak var btnDecrement: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
