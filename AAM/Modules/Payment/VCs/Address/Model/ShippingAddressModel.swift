//
//  ShippingAddress.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import Foundation

/// Model representing a shipping address.
struct ShippingAddress: Codable {
    var id: String?
    var fullName: String
    var address: String
    var flatOrBlockNo: String
    var postalCode: String
    var country: String
    var city: String
    var makeDefaultAddress: Bool
    var sameBillingAddress: Bool
    var isSelected: Bool? // Used for UI selection state, not stored in Firestore
    
    init(id: String? = nil, fullName: String, address: String, flatOrBlockNo: String, postalCode: String, country: String, city: String, makeDefaultAddress: Bool, sameBillingAddress: Bool, isSelected: Bool = false) {
        self.id = id
        self.fullName = fullName
        self.address = address
        self.flatOrBlockNo = flatOrBlockNo
        self.postalCode = postalCode
        self.country = country
        self.city = city
        self.makeDefaultAddress = makeDefaultAddress
        self.sameBillingAddress = sameBillingAddress
        self.isSelected = isSelected
    }
}

