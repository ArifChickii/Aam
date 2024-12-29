//
//  SellerListingsViewModel.swift
//  AAM
//
//  Created by Arif on 29/12/2024.
//


import Foundation
import FirebaseAuth

class SellerListingsViewModel {
    
    private let firebaseService = FirebaseService()
    
    // Array of products added by the current user
    private(set) var products: [ProductInfo] = [] {
        didSet {
            onProductsFetched?()
        }
    }
    
    // Callback to notify the VC once products are fetched
    var onProductsFetched: (() -> Void)?
    
    /// Fetch all products for the currently logged-in user
    func fetchUserProducts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        firebaseService.fetchProducts { [weak self] allProducts in
            // Filter the products by sellerId == current userId
            let userProducts = allProducts.filter({ (product: ProductInfo) -> Bool in
                return product.sellerId == userId
            })
            self?.products = userProducts
        }
    }
    
    // MARK: - Table Helpers
    func numberOfRows() -> Int {
        return products.count
    }
    
    func product(at index: Int) -> ProductInfo {
        return products[index]
    }
}
