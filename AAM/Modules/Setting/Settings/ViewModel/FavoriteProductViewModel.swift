//
//  FavouritesViewModel.swift
//  AAM
//
//  Created by Arif on 29/01/2025.
//

import Foundation
import FirebaseAuth

class FavouritesViewModel {
    
    private let firebaseService: FirebaseService
    
    // The array of favorite products for the current user
    private(set) var favouriteProducts: [ProductInfo] = [] {
        didSet {
            onFavouritesFetched?()
        }
    }
    
    // Callbacks
    var onFavouritesFetched: (() -> Void)?  // triggers when products are fetched
    var onError: ((String) -> Void)?        // triggers on error messages
    
    init(firebaseService: FirebaseService = FirebaseService()) {
        self.firebaseService = firebaseService
    }
    
    /// Fetches all favorite products for the current user.
    func fetchFavouriteProducts() {
        guard let _ = Auth.auth().currentUser else {
            onError?("User not logged in.")
            return
        }
        
        firebaseService.fetchFavoriteProducts { [weak self] result in
            switch result {
            case .success(let favProducts):
                self?.favouriteProducts = favProducts
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }
    
    // MARK: - Table Helpers
    
    func numberOfRows() -> Int {
        return favouriteProducts.count
    }
    
    func product(at index: Int) -> ProductInfo {
        return favouriteProducts[index]
    }
}

