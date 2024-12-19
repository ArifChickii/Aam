//
//  ProfileImageTblCell.swift
//  AAM
//
//  Created by Arif on 16/12/2024.
//

import UIKit

class ProfileImageTblCell: UITableViewCell {
    
    // MARK: - Identifier
    static let identifier = "ProfileImageTblCell"
    
    // MARK: - Outlets
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code if needed
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

