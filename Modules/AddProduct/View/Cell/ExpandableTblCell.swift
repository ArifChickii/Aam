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
    @IBOutlet weak var lblSubtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, subtitle: String){
        self.lblTitle.text = title
        self.lblSubtitle.text = subtitle
    }
    
}
