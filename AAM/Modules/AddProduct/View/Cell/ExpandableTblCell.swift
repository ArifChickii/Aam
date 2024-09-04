//
//  ExpandableTblCell.swift
//  AAM
//
//  Created by Mac on 03/09/2024.
//

import UIKit

class ExpandableTblCell: UITableViewCell {
    static let identifier = "ExpandableTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String){
        self.lblTitle.text = title
    }
    
}
