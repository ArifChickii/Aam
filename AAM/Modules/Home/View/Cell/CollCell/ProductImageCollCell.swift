//
//  ProductImageCollVell.swift
//  AAM
//
//  Created by Mac on 26/08/2024.
//

import UIKit

class ProductImageCollCell: UICollectionViewCell {
    static let identifier = "ProductImageCollVell"
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(imageUrl: String){
//        set image here from url 
    }

}
