//
//  SelectShippingAddressViewModel.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import Foundation

class SelectShippingAddressViewModel {
    // MARK: - Properties

    private let firebaseService = FirebaseService()
    private(set) var addresses: [ShippingAddress] = []
    var selectedAddressId: String?

    // Callbacks for updating the UI
    var onAddressesFetched: (() -> Void)?
    var onError: ((String) -> Void)?

    // MARK: - Methods

    /// Fetches shipping addresses from Firebase
    func fetchShippingAddresses() {
        firebaseService.fetchShippingAddresses { [weak self] result in
            switch result {
            case .success(let addresses):
                self?.addresses = addresses

                // Set the selectedAddressId to the default address if available
                if let defaultAddress = addresses.first(where: { $0.makeDefaultAddress }) {
                    self?.selectedAddressId = defaultAddress.id
                } else if let firstAddress = addresses.first {
                    // If no default address, select the first address
                    self?.selectedAddressId = firstAddress.id
                }
                self?.onAddressesFetched?()
            case .failure(let error):
                self?.onError?(error.localizedDescription)
            }
        }
    }

    /// Returns the number of addresses
    func numberOfAddresses() -> Int {
        return addresses.count
    }

    /// Returns the address at a specific index
    func address(at index: Int) -> ShippingAddress {
        return addresses[index]
    }

    /// Handles address selection with a completion handler
    func selectAddress(at index: Int, completion: @escaping (Bool) -> Void) {
        guard index < addresses.count else {
            completion(false)
            return
        }
        let selectedAddress = addresses[index]
        selectedAddressId = selectedAddress.id

        // Update the default address in Firebase
        updateDefaultAddress(selectedAddress: selectedAddress) { success in
            completion(success)
        }
    }

    /// Updates the default address in Firebase
    private func updateDefaultAddress(selectedAddress: ShippingAddress, completion: @escaping (Bool) -> Void) {
        // Set makeDefaultAddress to true for the selected address
        var updatedSelectedAddress = selectedAddress
        updatedSelectedAddress.makeDefaultAddress = true

        // Set makeDefaultAddress to false for other addresses
        let otherAddresses = addresses.filter { $0.id != selectedAddress.id }
        var updatedOtherAddresses = otherAddresses.map { address -> ShippingAddress in
            var address = address
            address.makeDefaultAddress = false
            return address
        }

        // Update the selected address in Firebase
        firebaseService.updateShippingAddress(address: updatedSelectedAddress) { [weak self] result in
            switch result {
            case .success():
                // Update other addresses
                let dispatchGroup = DispatchGroup()
                for address in updatedOtherAddresses {
                    dispatchGroup.enter()
                    self?.firebaseService.updateShippingAddress(address: address) { _ in
                        dispatchGroup.leave()
                    }
                }
                dispatchGroup.notify(queue: .main) {
                    // Refresh the addresses after updates
                    self?.fetchShippingAddresses()
                    completion(true)
                }
            case .failure(let error):
                self?.onError?(error.localizedDescription)
                completion(false)
            }
        }
    }
}



