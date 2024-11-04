//
//  ProductFormViewModel.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import Foundation
class ProductFormViewModel{
    var makeDefaultAddress = "Make this my default address"
    var saveBillingAddress = "Same billing address"
    let formFields: [ProductFormModel] = [
            ProductFormModel(title: "Full Name", placeHolder: "Enter your full name"),
            ProductFormModel(title: "Address", placeHolder: "Enter your address"),
            ProductFormModel(title: "Flat/Block No", placeHolder: "Enter flat/block number"),
            ProductFormModel(title: "Postal / Zipcode", placeHolder: "Enter postal/zipcode"),
            ProductFormModel(title: "Country", placeHolder: "Enter your country"),
            ProductFormModel(title: "City", placeHolder: "Enter your city"),
            ProductFormModel(title: "Make this my default address", placeHolder: ""),
            ProductFormModel(title: "Same billing address", placeHolder: "")
        ]
    
}
