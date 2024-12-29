//
//  SoldItemViewModel.swift
//  AAM
//
//  Created by Arif on 29/12/2024.
//

import Foundation

import FirebaseAuth

class SoldItemsViewModel {
    
    private let firebaseService = FirebaseService()
    
    // Array of sold products for the current user
    private(set) var soldProducts: [ProductInfo] = [] {
        didSet {
            // Notify the view controller (or any observer) that data is ready
            onSoldProductsFetched?()
        }
    }
    
    // Callback to notify the VC once sold products are fetched
    var onSoldProductsFetched: (() -> Void)?
    
    /// Fetch all products, filter those with status "sold" for the current user
    func fetchSoldProducts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        firebaseService.fetchProducts { [weak self] allProducts in
            // Filter for products added by the current user with "sold" status
            for obj in allProducts{
                print(obj.status)
            }
            let soldItems = allProducts.filter { product in
                
                product.sellerId == userId && product.status == "sold"
            }
            self?.soldProducts = soldItems
        }
    }
    
    // MARK: - Collection Helpers
    func numberOfItems() -> Int {
        return soldProducts.count
    }
    
    func product(at index: Int) -> ProductInfo {
        return soldProducts[index]
    }
}
