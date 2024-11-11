//
//  BagProduct.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import Foundation

/// Model representing a product in the bag with a count.
struct BagProduct: Codable {
    var id: String?
    var product: ProductInfo
    var count: Int
    
    init(product: ProductInfo, count: Int = 1) {
        self.id = product.id
        self.product = product
        self.count = count
    }
}

