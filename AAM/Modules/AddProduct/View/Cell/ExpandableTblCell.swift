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
    
    func configure(title: String, subtitles: [DropDown]? = nil,subcategory: String? = "", categoryType: Constants.CategoryType, prices: PriceModelForPassingBack? = nil){
        self.lblTitle.text = title
        if let subtitles = subtitles, subtitles.count > 0{
            let commaSeparatedTitle = subtitles.map { $0.title ?? "" }.joined(separator: ", ")
            self.lblSubtitle.text = commaSeparatedTitle
        }else{
            switch categoryType {
            case .category:
                if subcategory != ""{
                    self.lblSubtitle.text = subcategory
                }else{
                    self.lblSubtitle.text = "Please select category"
                }
            case .color:
                self.lblSubtitle.text = "Please select color"
            case .size:
                self.lblSubtitle.text = "Please select size"
            case .fabric:
                self.lblSubtitle.text = "Please select fabric"
            case .price:
                self.lblSubtitle.text = "Please select price"
                if let price = prices{
                    self.lblSubtitle.text = "Cut price: \(price.cutPrice)"
                    self.lblTitle.text = "Product price: \(price.price)"
                }
                
            default:
                self.lblSubtitle.text = "Please select color"
            }
        }
        
    }
    
}
