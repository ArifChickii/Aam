//
//  FormTblCell.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class FormTblCell: UITableViewCell {
    static let identifier = "FormTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txt: UITextField!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(obj: ProductFormModel){
        self.lblTitle.text = obj.title
        self.txt.placeholder = obj.placeHolder
    }
    
}
