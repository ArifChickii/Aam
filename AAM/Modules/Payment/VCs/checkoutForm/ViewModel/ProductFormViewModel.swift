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
    
    /// Populates the form fields with data from a `ShippingAddress`.
    func populateFormFields(with address: ShippingAddress) {
        for index in 0..<formFields.count {
            switch formFields[index].title {
            case "Full Name":
                formFields[index].value = address.fullName
            case "Address":
                formFields[index].value = address.address
            case "Flat/Block No":
                formFields[index].value = address.flatOrBlockNo
            case "Postal / Zipcode":
                formFields[index].value = address.postalCode
            case "Country":
                formFields[index].value = address.country
            case "City":
                formFields[index].value = address.city
            case "Make this my default address":
                formFields[index].value = address.makeDefaultAddress ? "true" : "false"
            case "Same billing address":
                formFields[index].value = address.sameBillingAddress ? "true" : "false"
            default:
                break
            }
        }
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

