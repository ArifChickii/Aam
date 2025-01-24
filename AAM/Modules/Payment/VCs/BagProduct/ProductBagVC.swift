//
//  ProductBagVC.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class ProductBagVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var productTblView: UITableView!
    
    /// Label shown when bag is empty
    @IBOutlet weak var emptyBagLabel: UILabel!
    
    /// The bottom button that either says "Proceed to checkout" or "Continue shopping"
    @IBOutlet weak var actionButton: UIButton!
    
    private let viewModel = ProductBagViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates
        setDelegatesAndDataSources()
        registerCells()
        
        // Observe bag products update
        setupViewModelCallbacks()
        
        // Initially hide table & label until we know the bag’s state
        productTblView.isHidden = true
        emptyBagLabel.isHidden  = true
        
        // Fetch bag products
        fetchBagProducts()
    }
    
    // MARK: - ViewModel Callbacks & Fetch
    private func setupViewModelCallbacks() {
        viewModel.onBagProductsUpdated = { [weak self] in
            DispatchQueue.main.async {
                self?.handleBagStateUI()
                self?.productTblView.reloadData()
            }
        }
        
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
                self?.showErrorAlert(message: errorMessage)
            }
        }
    }
    
    private func fetchBagProducts() {
        // Show loading indicator
        showLoadingIndicator()
        
        // Fetch products in the bag
        viewModel.fetchBagProducts { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoadingIndicator()
            }
        }
    }
    
    // MARK: - UI Updates for Empty/Non-Empty Bag
    /// Called any time bag data is updated to toggle UI states
    private func handleBagStateUI() {
        let isEmpty = viewModel.bagProducts.isEmpty
        
        if isEmpty {
            // If bag is empty, show message, hide table, rename button
            emptyBagLabel.isHidden  = false
            productTblView.isHidden = true
            
            // Button says "Continue Shopping"
            actionButton.setTitle("Continue Shopping", for: .normal)
            
        } else {
            // Bag has items, show table, hide message
            emptyBagLabel.isHidden  = true
            productTblView.isHidden = false
            
            // Button says "Proceed to checkout"
            actionButton.setTitle("Proceed to checkout", for: .normal)
        }
    }
    
    // MARK: - UITableView
    private func registerCells() {
        productTblView.register(UINib(nibName: ProductBagTblCell.identifier, bundle: nil),
                                forCellReuseIdentifier: ProductBagTblCell.identifier)
    }
    
    private func setDelegatesAndDataSources() {
        productTblView.delegate   = self
        productTblView.dataSource = self
    }
    
    // MARK: - IBActions
    
    @IBAction func backAction() {
        Router.pop(from: self)
    }
    
    /// The single bottom button that either continues shopping or goes to checkout
    @IBAction func proceedToCheckout() {
        let isEmpty = viewModel.bagProducts.isEmpty
        
        if isEmpty {
            // If bag empty => "Continue Shopping" => Go to Home
            Router.setHomeAsRootVC()
        } else {
            // If bag has items => Original checkout logic
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
                        // No addresses found, navigate to CheckoutFormVC
                        Router.MoveToCheckOutFormVC(from: self, addressToEdit: nil)
                    }
                }
            }
        }
    }
    
    // MARK: - Error Alert
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .default,
                                      handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ProductBagVC: UITableViewDelegate, UITableViewDataSource, ProductBagTblCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfBagProducts()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductBagTblCell.identifier,
            for: indexPath
        ) as? ProductBagTblCell else {
            return UITableViewCell()
        }
        
        let bagProduct = viewModel.bagProduct(at: indexPath.row)
        cell.configure(with: bagProduct)
        cell.delegate  = self
        cell.indexPath = indexPath
        
        return cell
    }
    
    // MARK: - ProductBagTblCellDelegate
    
    func incrementButtonTapped(at indexPath: IndexPath) {
        let bagProduct = viewModel.bagProduct(at: indexPath.row)
        let newCount   = bagProduct.count + 1
        viewModel.updateProductCount(at: indexPath.row, newCount: newCount) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Table reload is triggered by onBagProductsUpdated
                    break
                case .failure(let error):
                    self?.showErrorAlert(message: "Failed to update product count: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func decrementButtonTapped(at indexPath: IndexPath) {
        let bagProduct = viewModel.bagProduct(at: indexPath.row)
        let newCount   = bagProduct.count - 1
        viewModel.updateProductCount(at: indexPath.row, newCount: newCount) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    // Table reload is triggered by onBagProductsUpdated
                    break
                case .failure(let error):
                    self?.showErrorAlert(message: "Failed to update product count: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func deleteButtonTapped(at indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete",
                                      message: "Are you sure you want to delete this product from your bag?",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: nil))
        alert.addAction(UIAlertAction(title: "Delete",
                                      style: .destructive,
                                      handler: { [weak self] _ in
            self?.viewModel.deleteProduct(at: indexPath.row) { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success:
                        // reload triggered by onBagProductsUpdated
                        break
                    case .failure(let error):
                        self?.showErrorAlert(message: "Failed to delete product: \(error.localizedDescription)")
                    }
                }
            }
        }))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
}

