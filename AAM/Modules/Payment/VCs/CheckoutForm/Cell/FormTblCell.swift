//
//  FormTblCell.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

/// Delegate protocol to handle text changes in the form cell.
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
        // Initialization code
        txt.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        viewTxt.layer.borderWidth = 0
        viewTxt.layer.borderColor = UIColor.clear.cgColor
    }
    
    /// Configures the cell with a `ProductFormModel`.
    func configure(obj: ProductFormModel) {
        self.lblTitle.text = obj.title
        self.txt.placeholder = obj.placeHolder
        self.txt.text = obj.value
    }
    
    /// Sets validation error state.
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


