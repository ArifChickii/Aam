//
//  ProductNameAndDescTblCell.swift
//  AAM
//
//  Created by Mac on 03/09/2024.
//

import UIKit

protocol ProductTitleUpdateProtocol: AnyObject {
    func didUpdateTitle(text: String, at indexPath: IndexPath)
}
protocol ProductDescriptionUpdateProtocol: AnyObject {
    func didUpdateDesc(text: String, at indexPath: IndexPath)
}
//current these delegate are not used, but if need we can use to get more control of fields inside view controller
class ProductNameAndDescTblCell: UITableViewCell , UITextFieldDelegate{
    @IBOutlet weak var txtViewDesc: UITextView!
    @IBOutlet weak var txtField: UITextField!
    var indexPath: IndexPath!
    weak var delegateTitle: ProductTitleUpdateProtocol?
    weak var delegateDesc: ProductDescriptionUpdateProtocol?
    static let identifier = "ProductNameAndDescTblCell"
    let placeholderText = "Enter your text here..."
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        txtViewDesc.delegate = self
        txtField.delegate = self
        configurePlaceholder()
        
    }
    
    
    func configurePlaceholder() {
        if txtViewDesc.text.isEmpty{
            txtViewDesc.text = placeholderText
            txtViewDesc.textColor = UIColor.lightGray
            
            
        }
        
    }
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
            if let text = textField.text {
                delegateTitle?.didUpdateTitle(text: text, at: indexPath)
            }
        }
    
    
}
extension ProductNameAndDescTblCell: UITextViewDelegate{
    
    // UITextViewDelegate method - handling placeholder in shouldChangeTextIn
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // Combine the current text with the new input text to predict what the text will be
        let currentText: NSString = textView.text as NSString
        let updatedText = currentText.replacingCharacters(in: range, with: text)
        
        // If the text becomes empty, reset the placeholder
        if updatedText.isEmpty {
            textView.text = placeholderText
            textView.textColor = .lightGray
            textView.selectedRange = NSRange(location: 0, length: 0)
            return false
        }
        
        // Remove the placeholder when user starts typing
        if textView.textColor == .lightGray && !text.isEmpty {
            textView.text = nil
            textView.textColor = .black
        }
        
        return true
    }
    
    // Handle placeholder when textView becomes active
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .lightGray {
            textView.text = nil
            textView.textColor = .black
            
        }
    }
    
    // Re-add placeholder if textView is empty after editing
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            configurePlaceholder()
        }
    }
}

