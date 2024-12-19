//
//  ProfileFieldsTblCell.swift
//  AAM
//
//  Created by Arif on 16/12/2024.
//

import UIKit

class ProfileFieldsTblCell: UITableViewCell {
    
    // MARK: - Identifier
    static let identifier = "ProfileFieldsTblCell"
    
    // MARK: - Outlets
    @IBOutlet weak var nameStackView: UIStackView!
    @IBOutlet weak var emailStackView: UIStackView!
    @IBOutlet weak var locationStackView: UIStackView!
    @IBOutlet weak var countryStackView: UIStackView!
    @IBOutlet weak var bioStackView: UIStackView!
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var bioTextField: UITextField!
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code if needed
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

