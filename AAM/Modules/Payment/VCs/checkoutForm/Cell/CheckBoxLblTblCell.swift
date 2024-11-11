//
//  CheckBoxLblTblCell.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

/// Delegate protocol to handle checkbox value changes.
protocol CheckBoxLblTblCellDelegate: AnyObject {
    func checkBoxLblTblCell(_ cell: CheckBoxLblTblCell, didChangeValue isChecked: Bool)
}

class CheckBoxLblTblCell: UITableViewCell {
    static let identifier = "CheckBoxLblTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var imgCheckBox: UIImageView!
    
    weak var delegate: CheckBoxLblTblCellDelegate?
    private var isChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkBoxTapped))
        imgCheckBox.isUserInteractionEnabled = true
        imgCheckBox.addGestureRecognizer(tapGesture)
    }

    /// Configures the cell with title and checked state.
    func configure(isChecked: Bool, title: String) {
        self.isChecked = isChecked
        self.lblTitle.text = title
        self.updateCheckBoxImage()
    }
    
    private func updateCheckBoxImage() {
        self.imgCheckBox.image = isChecked ? UIImage(named: "checked") : UIImage(named: "uncheck")
    }
    
    @objc private func checkBoxTapped() {
        isChecked.toggle()
        updateCheckBoxImage()
        delegate?.checkBoxLblTblCell(self, didChangeValue: isChecked)
    }
}

