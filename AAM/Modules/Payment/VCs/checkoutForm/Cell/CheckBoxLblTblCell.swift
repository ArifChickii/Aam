//
//  CheckBoxLblTblCell.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class CheckBoxLblTblCell: UITableViewCell {
    static let identifier = "CheckBoxLblTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCheckBox: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(isChecked: Bool, title: String){
        self.lblTitle.text = title
        self.imgCheckBox.image = isChecked ? UIImage(named: "uncheck") : UIImage(named: "checked")
    }
    
}
