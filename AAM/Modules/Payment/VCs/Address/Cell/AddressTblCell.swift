//
//  AddressTblCell.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit

// MARK: - Protocol for Delegate
protocol AddressTblCellDelegate: AnyObject {
    /// Notifies the delegate that the delete button was tapped.
    /// - Parameter cell: The cell where the delete button was tapped.
    func addressTblCellDidTapDelete(_ cell: AddressTblCell)
    /// Notifies the delegate that the edit button was tapped.
        /// - Parameter cell: The cell where the edit button was tapped.
        func addressTblCellDidTapEdit(_ cell: AddressTblCell)
}

class AddressTblCell: UITableViewCell {
    @IBOutlet weak var lblShippingAddressTitle: UILabel!
    @IBOutlet weak var lblShippingAddress: UILabel!
    @IBOutlet weak var lblShippingUserName: UILabel!
    @IBOutlet weak var lblShippingZipCode: UILabel!
    @IBOutlet weak var lblShippingCountry: UILabel!
    @IBOutlet weak var imgRadio: UIImageView!
    @IBOutlet weak var btnRadioToSelectShippingAddress: UIButton!
    @IBOutlet weak var btnDeleteAddress: UIButton!
    @IBOutlet weak var btnEditAddress: UIButton!
    
    static let identifier = "AddressTblCell"
    
    // Delegate to notify about delete action
    weak var delegate: AddressTblCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        btnRadioToSelectShippingAddress.addTarget(self, action: #selector(radioButtonTapped), for: .touchUpInside)
        btnDeleteAddress.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        btnEditAddress.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }
    
    /// Configures the cell with a `ShippingAddress`.
    func configure(with address: ShippingAddress, isSelected: Bool) {
        lblShippingAddressTitle.text = address.address
        lblShippingUserName.text = address.fullName
        lblShippingZipCode.text = "\(address.postalCode ?? "")"
        lblShippingCountry.text = "\(address.city ?? ""), \(address.country ?? "")"
        lblShippingAddress.text = "\(address.flatOrBlockNo ?? "")"
        
        // Update radio button image
        let imageName = isSelected ? "ic_radio_selected" : "ic_radio_unselected"
        imgRadio.image = UIImage(named: imageName)
    }
    
    @objc private func radioButtonTapped() {
        // This method can be used if you prefer to handle selection via the button
        // Otherwise, selection is handled in didSelectRowAt
    }
    
    @objc private func deleteButtonTapped() {
        // Notify the delegate that delete button was tapped
        delegate?.addressTblCellDidTapDelete(self)
    }
    @objc private func editButtonTapped() {
            // Notify the delegate that edit button was tapped
            delegate?.addressTblCellDidTapEdit(self)
        }
}

