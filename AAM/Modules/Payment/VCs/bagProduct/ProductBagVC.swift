//
//  ProductBagVC.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class ProductBagVC: UIViewController, Storyboarded {
    @IBOutlet weak var productTblView: UITableView!
    private let viewModel = ProductBagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates and data sources
        setDelegatesAndDataSources()
        registerCells()
        
        // Observe bag products update
        viewModel.onBagProductsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.productTblView.reloadData()
            }
        }
        
        // Fetch bag products
        fetchBagProducts()
    }
    
    private func fetchBagProducts() {
        // Fetch products in the bag
        viewModel.fetchBagProducts {
            // Reload table view handled in onBagProductsUpdated
        }
    }
    
    private func registerCells() {
        productTblView.register(UINib(nibName: ProductBagTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductBagTblCell.identifier)
    }
    
    private func setDelegatesAndDataSources() {
        productTblView.delegate = self
        productTblView.dataSource = self
    }
    
    @IBAction func backAction() {
        Router.pop(from: self)
    }
    
    @IBAction func proceedToCheckout() {
        showLoadingIndicator()

        // Use the ViewModel to check for saved shipping addresses
        viewModel.userHasShippingAddresses { [weak self] hasAddresses in
            DispatchQueue.main.async {
                // Hide the loading indicator
                self?.hideLoadingIndicator()
                guard let self = self else { return }

                if hasAddresses {
                    // Addresses exist, navigate to SelectShippingAddressVC
                    Router.MoveToSelectShippingAddress(from: self)
                } else {
                    // No addresses found, navigate to CheckoutFormVC to add a new address
                    Router.MoveToCheckOutFormVC(from: self, addressToEdit: nil)
                }
            }
        }
    }

}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ProductBagVC: UITableViewDelegate, UITableViewDataSource, ProductBagTblCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfBagProducts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductBagTblCell.identifier, for: indexPath) as? ProductBagTblCell else {
            return UITableViewCell()
        }
        
        let bagProduct = viewModel.bagProduct(at: indexPath.row)
        cell.configure(with: bagProduct)
        cell.delegate = self
        cell.indexPath = indexPath // To know which cell triggered the action
        
        return cell
    }
    
    // MARK: - ProductBagTblCellDelegate Methods
    
    func incrementButtonTapped(at indexPath: IndexPath) {
        let bagProduct = viewModel.bagProduct(at: indexPath.row)
        let newCount = bagProduct.count + 1
        viewModel.updateProductCount(at: indexPath.row, newCount: newCount) { [weak self] result in
            switch result {
            case .success:
                // Update successful, table view will reload via onBagProductsUpdated
                break
            case .failure(let error):
                self?.showErrorAlert(message: "Failed to update product count: \(error.localizedDescription)")
            }
        }
    }
    
    func decrementButtonTapped(at indexPath: IndexPath) {
        let bagProduct = viewModel.bagProduct(at: indexPath.row)
        let newCount = bagProduct.count - 1
        viewModel.updateProductCount(at: indexPath.row, newCount: newCount) { [weak self] result in
            switch result {
            case .success:
                // Update successful, table view will reload via onBagProductsUpdated
                break
            case .failure(let error):
                self?.showErrorAlert(message: "Failed to update product count: \(error.localizedDescription)")
            }
        }
    }
    
    func deleteButtonTapped(at indexPath: IndexPath) {
        // Show confirmation alert
        let alert = UIAlertController(title: "Delete", message: "Are you sure you want to delete this product from your bag?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            self?.viewModel.deleteProduct(at: indexPath.row) { result in
                switch result {
                case .success:
                    // Deletion successful, table view will reload via onBagProductsUpdated
                    break
                case .failure(let error):
                    self?.showErrorAlert(message: "Failed to delete product: \(error.localizedDescription)")
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    // MARK: - TableView Delegate Method
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

