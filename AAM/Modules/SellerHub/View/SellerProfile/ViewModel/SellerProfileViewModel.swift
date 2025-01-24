//
//  SellerProfileViewModel.swift
//  AAM
//
//  Created by Arif on 26/12/2024.
//


import Foundation
import UIKit
import FirebaseAuth

/// ViewModel responsible for fetching seller profile info and products
class SellerProfileViewModel {
    
    private let firebaseService = FirebaseService()
    
    // Store user info
    var sellerInfo: UserModel? {
        didSet {
            // Once the seller's data is set, notify the VC to update UI
            self.onSellerInfoFetched?(sellerInfo)
        }
    }
    
    // Store products
    var products: [ProductInfo] = [] {
        didSet {
            // Once products are fetched, notify the VC to update the collection view
            self.onProductsFetched?()
        }
    }
    
    // Callbacks to notify the VC when data is fetched
    var onSellerInfoFetched: ((UserModel?) -> Void)?
    var onProductsFetched: (() -> Void)?
    
    /// Fetch the current user's info (assuming the seller is the logged-in user)
    func fetchSellerInfo() {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        firebaseService.fetchUserInformation(uid: uid) { [weak self] result in
            switch result {
            case .success(let userModel):
                self?.sellerInfo = userModel
            case .failure(let error):
                print("Error fetching seller info: \(error.localizedDescription)")
            }
        }
    }
    
    /// Fetch all products (you can customize this to fetch only the seller's products if needed)
    func fetchAllProducts() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("User not logged in")
            return
        }
        
        firebaseService.fetchProducts { [weak self] allProducts in
            // Filter the products by sellerId == current userId
            print(allProducts.count)
            
            let userProducts = allProducts.filter({ (product: ProductInfo) -> Bool in
                
                return product.sellerId == userId
            })
            self?.products = userProducts
        }
        
        
    }
}
