//
//  ShippingAddress.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import Foundation

/// Model representing a shipping address.
struct ShippingAddress: Codable {
    var fullName: String
    var address: String
    var flatOrBlockNo: String
    var postalCode: String
    var country: String
    var city: String
    var makeDefaultAddress: Bool
    var sameBillingAddress: Bool
}

