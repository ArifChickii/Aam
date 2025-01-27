//
//  OrderInfoViewModel.swift
//  AAM
//
//  Created by Arif on 30/11/2024.
//

import Foundation

class OrderInfoViewModel {
    
    // MARK: - Properties
    let bagProducts: [BagProduct]
    let selectedAddress: ShippingAddress
    
    var totalProductPrice: Double = 0.0
    let tax: Double = 5.0    // Static value
    let shippingCost: Double = 10.0 // Static value
    var grandTotal: Double = 0.0
    
    private let firebaseService = FirebaseService()
    
    // MARK: - Init
    init(bagProducts: [BagProduct], selectedAddress: ShippingAddress) {
        self.bagProducts      = bagProducts
        self.selectedAddress  = selectedAddress
        calculateTotals()
    }
    
    // MARK: - Private Helpers
    private func calculateTotals() {
        totalProductPrice = bagProducts.reduce(0) { (result, bagProduct) -> Double in
            let price = Double(bagProduct.product.price ?? "0") ?? 0
            return result + (price * Double(bagProduct.count))
        }
        grandTotal = totalProductPrice + tax + shippingCost
    }
    
    // MARK: - Table Helpers
    func numberOfSections() -> Int {
        return 2 // 0: Products, 1: Address
    }
    
    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return bagProducts.count
        } else if section == 1 {
            return 1 // Address cell
        }
        return 0
    }
    
    // MARK: - Creating Orders
    func createOrder() -> Order {
        // Construct a new order object
        let order = Order(
            id: nil,              // assigned by Firebase
            userId: nil,          // set in FirebaseService.saveOrder()
            bagProducts: bagProducts,
            selectedAddress: selectedAddress,
            tax: tax,
            shippingCost: shippingCost,
            grandTotal: grandTotal,
            orderDate: Date(),    // current date/time
            status: "created"     // initial status
        )
        return order
    }
    
    // MARK: - Mark Products as Sold
    /// Example method to mark all bag products as sold.
    /// If you only want to mark a single product, you can adapt this method accordingly.
    func markAllProductsAsSold(completion: @escaping (Result<Void, Error>) -> Void) {
        // We'll call markProductAsSold on each product's ID
        let group = DispatchGroup()
        var lastError: Error? = nil
        
        for bagProduct in bagProducts {
            group.enter()
            let productId = bagProduct.product.id ?? ""
            
            firebaseService.markProductAsSold(productId: productId) { result in
                defer { group.leave() }
                switch result {
                case .success():
                    print("Marked product ID=\(productId) as sold.")
                case .failure(let error):
                    print("Failed to mark product ID=\(productId) as sold: \(error.localizedDescription)")
                    lastError = error
                }
            }
        }
        
        group.notify(queue: .main) {
            if let error = lastError {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
}

