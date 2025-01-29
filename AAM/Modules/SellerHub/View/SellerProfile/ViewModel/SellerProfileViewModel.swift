//
//  SellerProfileViewModel.swift
//  AAM
//
//  Created by Arif on 26/12/2024.
//

import Foundation
import UIKit
import FirebaseAuth

class SellerProfileViewModel {
    
    private let firebaseService = FirebaseService()
    
    /// The userId we want to display. If nil => use current logged-in user.
    let userId: String?
    
    // MARK: - Observables / Callbacks
    var onSellerInfoFetched: ((UserModel?) -> Void)?
    var onProductsFetched: (() -> Void)?
    
    // MARK: - Data
    var sellerInfo: UserModel? {
        didSet {
            onSellerInfoFetched?(sellerInfo)
        }
    }
    
    var products: [ProductInfo] = [] {
        didSet {
            onProductsFetched?()
        }
    }
    
    // MARK: - Init
    init(userId: String?) {
        self.userId = userId
    }
    
    // MARK: - Fetch Seller Info
    func fetchSellerInfo() {
        // If userId is nil => show current user
        if let explicitUserId = userId {
            getUserInfo(for: explicitUserId)
        } else {
            guard let currentUid = Auth.auth().currentUser?.uid else {
                print("No current user logged in, userId is also nil.")
                return
            }
            getUserInfo(for: currentUid)
        }
    }
    
    // MARK: - Fetch Seller Products
    func fetchAllProducts() {
        let finalUserId: String
        if let id = userId {
            finalUserId = id
        } else {
            guard let currentUid = Auth.auth().currentUser?.uid else {
                print("No current user & userId nil.")
                return
            }
            finalUserId = currentUid
        }
        
        // Fetch all products & filter by sellerId
        firebaseService.fetchProducts { [weak self] allProducts in
            guard let self = self else { return }
            let userProducts = allProducts.filter { product in
                product.sellerId == finalUserId
            }
            self.products = userProducts
        }
    }
    
    // MARK: - Helper: actually fetch user doc
    private func getUserInfo(for uid: String) {
        firebaseService.fetchUserInformation(uid: uid) { [weak self] result in
            switch result {
            case .success(let userModel):
                self?.sellerInfo = userModel
            case .failure(let error):
                print("Error fetching user info: \(error.localizedDescription)")
                self?.sellerInfo = nil
            }
        }
    }
}

