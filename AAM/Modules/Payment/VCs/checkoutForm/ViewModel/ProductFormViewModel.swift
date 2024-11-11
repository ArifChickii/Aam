//
//  ProductFormViewModel.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import Foundation

class ProductFormViewModel {
    var makeDefaultAddress = "Make this my default address"
    var saveBillingAddress = "Same billing address"
    
    var formFields: [ProductFormModel] = []
    
    init() {
        formFields = [
            ProductFormModel(title: "Full Name", placeHolder: "Enter your full name", value: nil, isRequired: true),
            ProductFormModel(title: "Address", placeHolder: "Enter your address", value: nil, isRequired: true),
            ProductFormModel(title: "Flat/Block No", placeHolder: "Enter flat/block number", value: nil, isRequired: true),
            ProductFormModel(title: "Postal / Zipcode", placeHolder: "Enter postal/zipcode", value: nil, isRequired: true),
            ProductFormModel(title: "Country", placeHolder: "Enter your country", value: nil, isRequired: true),
            ProductFormModel(title: "City", placeHolder: "Enter your city", value: nil, isRequired: true),
            ProductFormModel(title: "Make this my default address", placeHolder: "", value: "false", isRequired: false),
            ProductFormModel(title: "Same billing address", placeHolder: "", value: "false", isRequired: false)
        ]
    }
    
    /// Retrieves the value for a given field title.
    func getValueForTitle(_ title: String) -> String? {
        return formFields.first(where: { $0.title == title })?.value
    }
    
    /// Retrieves the Boolean value for a given field title.
    func getBoolValueForTitle(_ title: String) -> Bool {
        if let value = formFields.first(where: { $0.title == title })?.value {
            return value == "true"
        }
        return false
    }
}

