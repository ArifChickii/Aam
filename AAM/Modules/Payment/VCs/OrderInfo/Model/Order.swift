//
//  Order.swift
//  AAM
//
//  Created by Arif on 19/12/2024.
//

import Foundation

struct Order: Codable {
    var id: String? // Firestore generated ID
    var userId: String? // ID of the user placing the order
    var bagProducts: [BagProduct]
    var selectedAddress: ShippingAddress
    var tax: Double
    var shippingCost: Double
    var grandTotal: Double
    var orderDate: Date
    var status: String // e.g. "created", "processing", etc.
}
