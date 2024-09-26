//
//  BottomSheetTblCell.swift
//  AAM
//
//  Created by Mac on 11/09/2024.
//

import UIKit

class BottomSheetTblCell: UITableViewCell {
    static let identifier = "BottomSheetTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewColor: UIView!
    @IBOutlet weak var imgCheckbox: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(obj : DropDown? = nil, objCategory: ProductCategory? = nil, type: Constants.CategoryType){
        self.viewColor.isHidden = true
        
        if type == .category {
            if let objCategory = objCategory{
                self.lblTitle.text = objCategory.title
            }
            self.imgCheckbox.image = UIImage(named: "ic_arrow_right")
        }else{
            if let obj = obj{
                self.lblTitle.text = obj.title
                if type != .subCategory{
                    self.imgCheckbox.image = obj.isChecked ?? false ? UIImage(named: "ic_checked") : UIImage(named: "ic_unchecked")
                }else{
                    self.imgCheckbox.image = UIImage(named: "ic_arrow_right")
                }
                
            }
        }
        

        
 
        

    }
    
}
