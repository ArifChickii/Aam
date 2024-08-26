//
//  ProductImageCellColl.swift
//  AAM
//
//  Created by Mac on 26/08/2024.
//

import UIKit
import SDWebImage

class ProductImageCellColl: UICollectionViewCell {
    static let identifier = "ProductImageCellColl"
    @IBOutlet weak var img: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(imageUrl: String){
//        set image here from url
       

        img.sd_setImage(with: URL(string: imageUrl), placeholderImage: UIImage(named: "dummy"))
    }
}
