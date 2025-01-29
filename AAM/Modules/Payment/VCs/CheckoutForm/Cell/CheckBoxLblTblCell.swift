//
//  CheckBoxLblTblCell.swift
//  AAM
//

import UIKit

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
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(checkBoxTapped))
        imgCheckBox.isUserInteractionEnabled = true
        imgCheckBox.addGestureRecognizer(tapGesture)
    }
    
    func configure(isChecked: Bool, title: String) {
        self.isChecked = isChecked
        lblTitle.text  = title
        updateCheckBoxImage()
    }
    
    private func updateCheckBoxImage() {
        imgCheckBox.image = isChecked ? UIImage(named: "checked") : UIImage(named: "uncheck")
    }
    
    @objc private func checkBoxTapped() {
        isChecked.toggle()
        updateCheckBoxImage()
        delegate?.checkBoxLblTblCell(self, didChangeValue: isChecked)
    }
}

