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
    var address: String?           // Street address
    var flatOrBlockNo: String?
    var postalCode: String?
    var country: String?
    var city: String?
    var state: String?             // Added 'state' property
    var makeDefaultAddress: Bool
    var sameBillingAddress: Bool
    var isSelected: Bool?          // Used for UI selection state, not stored in Firestore
    
    init(id: String? = nil,
         fullName: String,
         address: String?,
         flatOrBlockNo: String?,
         postalCode: String?,
         country: String?,
         city: String?,
         state: String?,            // Included 'state' in initializer
         makeDefaultAddress: Bool,
         sameBillingAddress: Bool,
         isSelected: Bool = false) {
        self.id = id
        self.fullName = fullName
        self.address = address
        self.flatOrBlockNo = flatOrBlockNo
        self.postalCode = postalCode
        self.country = country
        self.city = city
        self.state = state
        self.makeDefaultAddress = makeDefaultAddress
        self.sameBillingAddress = sameBillingAddress
        self.isSelected = isSelected
    }
}

extension ShippingAddress {
    /// Provides a full address description by concatenating available address components.
    var fullDescription: String {
        var components = [String]()
        if let address = self.address, !address.isEmpty {
            components.append(address)
        }
        if let flatOrBlockNo = self.flatOrBlockNo, !flatOrBlockNo.isEmpty {
            components.append(flatOrBlockNo)
        }
        if let city = self.city, !city.isEmpty {
            components.append(city)
        }
        if let state = self.state, !state.isEmpty {
            components.append(state)
        }
        if let postalCode = self.postalCode, !postalCode.isEmpty {
            components.append(postalCode)
        }
        if let country = self.country, !country.isEmpty {
            components.append(country)
        }
        return components.joined(separator: ", ")
    }
}
