//
//  AddCardInfoViewModel.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import Foundation
class AddCardInfoViewModel{
    let formFields: [ProductFormModel] = [
            ProductFormModel(title: "Card name", placeHolder: "Enter Card Name"),
            ProductFormModel(title: "Card number", placeHolder: "000 - 000 - 000 - 000"),
            ProductFormModel(title: "CVV", placeHolder: "Enter code"),
            
        ]
}
