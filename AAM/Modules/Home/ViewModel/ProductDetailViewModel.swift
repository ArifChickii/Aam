//
//  ProductDetailViewModel.swift
//  AAM
//
//  Created by Mac on 27/08/2024.
//

import Foundation
import FirebaseAuth  // Import FirebaseAuth to get currentUser

class ProductDetailViewModel {
    // The product being displayed
    var product: ProductInfo
    
    // Service to interact with Firebase
    private let productService = FirebaseService()
    
    // Property to indicate if the product is in the bag
    var isProductInBag: Bool = false

    init(product: ProductInfo) {
        self.product = product
    }
    
    /// Determines whether the logged-in user is the seller of this product.
    /// The `sellerId` on the product must match the currentUser's uid from FirebaseAuth.
    var isCurrentUserSeller: Bool {
        // Safely unwrap the product's seller ID and FirebaseAuth's current user ID
        guard let sellerId = product.sellerId,
              let currentUserId = Auth.auth().currentUser?.uid else {
            return false
        }
        return sellerId == currentUserId
    }
    
    /// Generates a custom URL for the product
    func generateCustomURL(for product: ProductInfo) -> URL {
        return URL(string: "aamApp://product/\(product.id)")!
    }
    
    /// Checks if the product is already in the bag
    /// - Parameter completion: Closure returning a Bool indicating the result
    func checkIfProductIsInBag(completion: @escaping (Bool) -> Void) {
        guard let productId = product.id else {
            completion(false)
            return
        }
        productService.checkProductInBag(productId: productId) { [weak self] isInBag in
            self?.isProductInBag = isInBag
            completion(isInBag)
        }
    }
    
    /// Adds the product to the bag
    /// - Parameter completion: Closure returning a Result indicating success or failure
    func addToBag(completion: @escaping (Result<Void, Error>) -> Void) {
        productService.addProductToBag(product: product) { [weak self] result in
            if case .success = result {
                self?.isProductInBag = true
            }
            completion(result)
        }
    }
    
    /// Deletes the product
    /// - Parameter completion: Closure returning a Result indicating success or failure
    func deleteProduct(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let productId = product.id else {
            completion(.failure(NSError(domain: "ProductDetailViewModel",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "Product ID not found"])))
            return
        }
        productService.deleteProduct(productId: productId, completion: completion)
    }
}

