//
//  AdditionalInfoTblCell.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit

class AdditionalInfoTblCell: UITableViewCell {
    static let identifier = "AdditionalInfoTblCell"
    @IBOutlet weak var lblAddressDescription: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(with address: ShippingAddress) {
            lblAddressDescription.text = address.fullDescription
        }
}
