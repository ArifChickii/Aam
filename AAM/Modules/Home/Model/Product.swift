//
//  Product.swift
//  AAM
//
//  Created by Arif ww on 25/08/2024.
//

import Foundation
struct Product: Codable {
    var id: String?
    let images: [String]?
    let title: String?
    let description: String?
    let size: String?
    let category: [String]?
    let price: Double?
    let color: String?
    let rating: String?
    let cutPrice: Double?
}


struct ProductInfo {
    var id: String
    let images: [String]?
    let sizes: [String]?
    let colors: [String]?
    let fabrics: [String]?
    let category: ProductCategory?
    let subCategory: String?
    let title: String?
    let description: String?
    let price: String?
    let rating: String?
    let cutPrice: Double?
}


struct ProductCategory {
    let title: String?
    let subCategories: [String]?
}



