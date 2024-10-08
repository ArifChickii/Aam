//
//  ProductCategoryTitleCollCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductCategoryTitleCollCell: UICollectionViewCell {
    static let identifier = "ProductCategoryTitleCollCell"
    @IBOutlet weak var lblCategory: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    func configure(title: String){
        self.lblCategory.text = title
    }

}
