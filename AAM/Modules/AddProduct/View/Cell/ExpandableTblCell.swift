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
    @IBOutlet weak var viewBg: UIView!
    @IBOutlet weak var lblSubtitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(title: String, subtitles: [String]? = nil, productCategory: ProductCategory? = nil, categoryType: Constants.CategoryType, prices: PriceModelForPassingBack? = nil, showBorder: Bool){
        self.lblTitle.text = title
        if let subtitles = subtitles, subtitles.count > 0{
            let commaSeparatedTitle = subtitles.joined(separator: ", ")
            self.lblSubtitle.text = commaSeparatedTitle
        }else{
            switch categoryType {
            case .category:
                
                if let category = productCategory{
                    self.lblSubtitle.text = "\(category.title ?? "") -> \(category.subCategories?[0] ?? "")"
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
        
        if showBorder{
            self.viewBg.addRemoveAbleBorder(color: .red, width: 1.0)
            
        }else{
            self.viewBg.removeBorders()
        }
        
    }
    
}
