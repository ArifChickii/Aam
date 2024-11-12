//
//  SelectShippingAddressViewModel.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import Foundation

class SelectShippingAddressViewModel {
    private let firebaseService: FirebaseService
    var shippingAddresses: [ShippingAddress] = []
    var selectedAddressId: String?
    var onAddressesFetched: (() -> Void)?
    var onError: ((String) -> Void)?
    
    init(firebaseService: FirebaseService = FirebaseService()) {
        self.firebaseService = firebaseService
    }
    
    /// Fetches shipping addresses from Firebase.
    func fetchShippingAddresses() {
        firebaseService.fetchShippingAddresses { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let addresses):
                    self?.shippingAddresses = addresses
                    // Set default selection if any
                    if let defaultAddress = addresses.first(where: { $0.makeDefaultAddress }) {
                        self?.selectedAddressId = defaultAddress.id
                    }
                    self?.onAddressesFetched?()
                case .failure(let error):
                    self?.onError?(error.localizedDescription)
                }
            }
        }
    }
    
    /// Returns the number of addresses.
    func numberOfAddresses() -> Int {
        return shippingAddresses.count
    }
    
    /// Returns the address at the specified index.
    func address(at index: Int) -> ShippingAddress {
        return shippingAddresses[index]
    }
    
    /// Handles selection of an address.
    func selectAddress(at index: Int) {
        let selectedAddress = shippingAddresses[index]
        selectedAddressId = selectedAddress.id
    }
}

