//
//  Product.swift
//  AAM
//
//  Created by Arif ww on 25/08/2024.
//

import Foundation
import FirebaseFirestoreInternal
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

struct ProductInfo: Codable, Hashable {
    var id: String?
    var sellerId: String?
    var images: [String]?
    var sizes: [String]?
    var colors: [String]?
    var fabrics: [String]?
    var category: ProductCategory?
    var title: String?
    var description: String?
    var price: String?
    var rating: String?
    var cutPrice: String?
    
    // Instead of a Timestamp, use a String
    var createdAt: String? // e.g., "2024-12-29T20:15:00+0000"

    var status: String? // "active", "sold", etc.

    // Ensure you conform to Hashable as needed
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ProductInfo, rhs: ProductInfo) -> Bool {
        return lhs.id == rhs.id
    }
}



struct ProductCategory: Codable{
    let title: String?
    let subCategories: [String]?
}

struct ProductCategoryForDataRecieving {
    let title: String?
    let subCategories: [DropDown]?
}



