//
//  OrderInfoTblCell.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit

class OrderInfoTblCell: UITableViewCell {
    static let identifier = "OrderInfoTblCell"
    
    @IBOutlet weak var lblProductName: UILabel!
        @IBOutlet weak var lblProductPrice: UILabel!
        @IBOutlet weak var lblTax: UILabel!
        @IBOutlet weak var lblShippingPrice: UILabel!
        @IBOutlet weak var lblTotalPrice: UILabel!
        @IBOutlet weak var totalView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with bagProduct: BagProduct, showTotal: Bool, totalPrice: Double, tax: Double, shippingCost: Double) {
            lblProductName.text = bagProduct.product.title ?? ""
            let price = Double(bagProduct.product.price ?? "0") ?? 0
            let totalProductPrice = price * Double(bagProduct.count)
            lblProductPrice.text = "$\(String(format: "%.2f", totalProductPrice))"
            
            if showTotal {
                totalView.isHidden = false
                lblTax.text = "$\(String(format: "%.2f", tax))"
                lblShippingPrice.text = "$\(String(format: "%.2f", shippingCost))"
                lblTotalPrice.text = "$\(String(format: "%.2f", totalPrice))"
            } else {
                totalView.isHidden = true
            }
        }
    
}
