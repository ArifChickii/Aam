//
//  OrderInfoViewModel.swift
//  AAM
//
//  Created by Arif on 30/11/2024.
//

import Foundation


class OrderInfoViewModel {
    let bagProducts: [BagProduct]
    let selectedAddress: ShippingAddress
    var totalProductPrice: Double = 0.0
    let tax: Double = 5.0 // Static value
    let shippingCost: Double = 10.0 // Static value
    var grandTotal: Double = 0.0
    
    init(bagProducts: [BagProduct], selectedAddress: ShippingAddress) {
        self.bagProducts = bagProducts
        self.selectedAddress = selectedAddress
        calculateTotals()
    }
    
    private func calculateTotals() {
        totalProductPrice = bagProducts.reduce(0) { (result, bagProduct) -> Double in
            let price = Double(bagProduct.product.price ?? "0") ?? 0
            return result + (price * Double(bagProduct.count))
        }
        grandTotal = totalProductPrice + tax + shippingCost
    }
    
    func numberOfSections() -> Int {
        return 2 // Products and Address sections
    }
    
    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return bagProducts.count
        } else if section == 1 {
            return 1 // Address cell
        }
        return 0
    }
    
    func createOrder() -> Order {
        // Construct a new order object
        let order = Order(
            id: nil, // will be assigned by Firebase
            userId: nil, // will be set in FirebaseService.saveOrder()
            bagProducts: bagProducts,
            selectedAddress: selectedAddress,
            tax: tax,
            shippingCost: shippingCost,
            grandTotal: grandTotal,
            orderDate: Date(), // current date/time as orderDate
            status: "created" // initial status
        )
        return order
    }
}
