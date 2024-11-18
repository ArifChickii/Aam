//
//  AddressTblCell.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit

class AddressTblCell: UITableViewCell {
    @IBOutlet weak var lblShippingAddressTitle: UILabel!
    @IBOutlet weak var lblShippingAddress: UILabel!
    @IBOutlet weak var lblShippingUserName: UILabel!
    @IBOutlet weak var lblShippingZipCode: UILabel!
    @IBOutlet weak var lblShippingCountry: UILabel!
    @IBOutlet weak var imgRadio: UIImageView!
    @IBOutlet weak var btnRadioToSelectShippingAddress: UIButton!
    
    static let identifier = "AddressTblCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnRadioToSelectShippingAddress.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
    }
    
    /// Configures the cell with a `ShippingAddress`.
    func configure(with address: ShippingAddress, isSelected: Bool) {
        lblShippingAddressTitle.text = address.address
        lblShippingUserName.text = address.fullName
        lblShippingZipCode.text = "Zip Code: \(address.postalCode)"
        lblShippingCountry.text = "\(address.city), \(address.country)"
        lblShippingAddress.text = "Flat/Block No: \(address.flatOrBlockNo)"
        
        // Update radio button image
        
        let imageName = isSelected ? "ic_radio_selected" : "ic_radio_unselected"
        imgRadio.image = UIImage(named: imageName)
    }
    
    
    @objc private func radioButtonTapped() {
        // This method can be used if you prefer to handle selection via the button
        // Otherwise, selection is handled in didSelectRowAt
    }
}

