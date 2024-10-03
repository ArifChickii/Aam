//
//  PickPhotoCollCell.swift
//  AAM
//
//  Created by Mac on 03/09/2024.
//

import UIKit

class PickPhotoCollCell: UICollectionViewCell {
    static let identifier = "PickPhotoCollCell"
    @IBOutlet weak var imgAdd: UIImageView!
    @IBOutlet weak var imgAdded: UIImageView!
    @IBOutlet weak var viewBg: UIView!
    var showBorder = false
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if showBorder {
            self.viewBg.removeBorders()
            self.viewBg.addRemoveAbleBorder(color: .red, width: 1.0)
        } else {
            self.viewBg.removeBorders()
        }
    }

}
