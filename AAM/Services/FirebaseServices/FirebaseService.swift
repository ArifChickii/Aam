//
//  FirebaseService.swift
//  AAM
//
//  Created by Arif ww on 25/08/2024.
//

import Foundation

import FirebaseFirestore

class FirebaseService {
    private var db = Firestore.firestore()

    func fetchProducts(completion: @escaping ([Product]) -> Void) {
        db.collection("Products").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                var products: [Product] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let product = Product(
                        id: document.documentID,
                        images: data["image"] as? [String] ?? [],
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        size: data["size"] as? String ?? "",
                        category: data["category"] as? String ?? "",
                        price: data["price"] as? Double ?? 0.0,
                        color: data["color"] as? String ?? "",
                        rating: data["rating"] as? String ?? "0.0",
                        cutPrice: data["cutPrice"] as? Double ?? 0.0
                    )
                    products.append(product)
                }
                completion(products)
            }
        }
    }
}
