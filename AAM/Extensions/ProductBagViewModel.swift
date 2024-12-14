//
//  ProductBagViewModel.swift
//  AAM
//
//  Created by Arif on 11/11/2024.
//

import Foundation

/// ViewModel for the Product Bag screen.
class ProductBagViewModel {
    private let productService: FirebaseService
    private(set) var bagProducts: [BagProduct] = []
    var onBagProductsUpdated: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
    }
    
    /// Fetches products in the bag from Firebase.
    func fetchBagProducts(completion: (() -> Void)? = nil) {
        productService.fetchBagProducts { [weak self] result in
            switch result {
            case .success(let bagProducts):
                self?.bagProducts = bagProducts
                self?.onBagProductsUpdated?()
                completion?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
                completion?()
            }
        }
    }
    
    /// Returns the number of products in the bag.
    func numberOfBagProducts() -> Int {
        return bagProducts.count
    }
    
    /// Returns the `BagProduct` at the specified index.
    func bagProduct(at index: Int) -> BagProduct {
        return bagProducts[index]
    }
    
    /// Updates the count of a product in the bag.
    func updateProductCount(at index: Int, newCount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let productId = bagProducts[index].id ?? ""
        productService.updateBagProductCount(productId: productId, newCount: newCount) { [weak self] result in
            switch result {
            case .success:
                // Update local data
                if newCount <= 0 {
                    // Remove product from array
                    self?.bagProducts.remove(at: index)
                } else {
                    // Update count
                    self?.bagProducts[index].count = newCount
                }
                self?.onBagProductsUpdated?()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Deletes a product from the bag.
    func deleteProduct(at index: Int, completion: @escaping (Result<Void, Error>) -> Void) {
        let productId = bagProducts[index].id ?? ""
        productService.deleteBagProduct(withId: productId) { [weak self] result in
            switch result {
            case .success:
                // Remove product from array
                self?.bagProducts.remove(at: index)
                self?.onBagProductsUpdated?()
                completion(.success(()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    /// Checks if the user has any shipping addresses saved.
    /// - Parameter completion: Closure returning a Bool indicating if addresses exist.
    func userHasShippingAddresses(completion: @escaping (Bool) -> Void) {
        productService.fetchShippingAddresses { result in
            switch result {
            case .success(let addresses):
                completion(!addresses.isEmpty)
            case .failure(_):
                // Handle the error as needed.
                completion(false)
            }
        }
    }
}

