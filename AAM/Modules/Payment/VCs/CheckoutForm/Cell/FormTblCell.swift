//
//  FormTblCell.swift
//  AAM
//

import UIKit

protocol FormTblCellDelegate: AnyObject {
    func formTblCell(_ cell: FormTblCell, didUpdateText text: String?)
}

class FormTblCell: UITableViewCell {
    static let identifier = "FormTblCell"
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var txt: UITextField!
    @IBOutlet weak var viewTxt: UIView!
    
    weak var delegate: FormTblCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        txt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        viewTxt.layer.borderWidth = 0
        viewTxt.layer.borderColor = UIColor.clear.cgColor
    }
    
    /// Configure the cell with data
    func configure(obj: ProductFormModel) {
        lblTitle.text        = obj.title
        txt.placeholder      = obj.placeHolder
        txt.text             = obj.value
    }
    
    /// Set a red border if there's a validation error
    func setValidationError(_ hasError: Bool) {
        if hasError {
            viewTxt.layer.borderWidth = 1
            viewTxt.layer.borderColor = UIColor.red.cgColor
        } else {
            viewTxt.layer.borderWidth = 0
            viewTxt.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.formTblCell(self, didUpdateText: textField.text)
    }
}

