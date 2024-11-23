//
//  SelectShippingAddressVC.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit

class SelectShippingAddressVC: UIViewController, Storyboarded {
    @IBOutlet weak var addressTblView: UITableView!
    private let viewModel = SelectShippingAddressViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup
        setDelegatesAndDataSources()
        registerCells()
        setupViewModelCallbacks()
        
        // Fetch addresses
        fetchShippingAddresses()
    }
    
    private func setupViewModelCallbacks() {
          viewModel.onAddressesFetched = { [weak self] in
              self?.addressTblView.reloadData()
              // Hide loader if any
              self?.hideLoadingIndicator()
          }

          viewModel.onError = { [weak self] errorMessage in
              self?.hideLoadingIndicator()
              self?.showAlert(title: "Error", message: errorMessage)
          }
      }
    
    private func fetchShippingAddresses() {
        // Show loader
        showLoadingIndicator()
        viewModel.fetchShippingAddresses()
    }
    
    private func registerCells() {
        addressTblView.register(UINib(nibName: AddressTblCell.identifier, bundle: nil), forCellReuseIdentifier: AddressTblCell.identifier)
        addressTblView.estimatedRowHeight = 200
        addressTblView.rowHeight = UITableView.automaticDimension
    }
    
    private func setDelegatesAndDataSources() {
        addressTblView.delegate = self
        addressTblView.dataSource = self
    }
    
    @IBAction func backAction() {
        Router.pop(from: self)
    }
    
    @IBAction func addAddress(){
        Router.MoveToCheckOutFormVC(from: self)
    }
    
    @IBAction func continueAction() {
        // Proceed with selected address
        if let selectedAddressId = viewModel.selectedAddressId {
            print("Selected Address ID: \(selectedAddressId)")
            // You can pass the selected address to the next screen as needed
            Router.MoveToSelectPaymentMethod(from: self)
        } else {
            showAlert(title: "Error", message: "Please select a shipping address.")
        }
    }

    
    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title,
                                                message: message,
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK",
                                     style: .default)
        alertController.addAction(okAction)
        present(alertController, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension SelectShippingAddressVC: UITableViewDelegate, UITableViewDataSource, AddressTblCellDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let count = viewModel.numberOfAddresses()
        if count == 0 {
            // Show placeholder or empty state if needed
        }
        return count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddressTblCell.identifier, for: indexPath) as? AddressTblCell else {
            return UITableViewCell()
        }

        let address = viewModel.address(at: indexPath.row)
        let isSelected = address.id == viewModel.selectedAddressId
        cell.configure(with: address, isSelected: isSelected)
        cell.delegate = self

        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Show loader
        showLoadingIndicator()

        // Update selection in ViewModel
        viewModel.selectAddress(at: indexPath.row) { [weak self] success in
            DispatchQueue.main.async {
                // Hide loader
                self?.hideLoadingIndicator()

                if success {
                    // Reload table view to reflect changes
                    self?.addressTblView.reloadData()
                } else {
                    // Handle error if needed
                    self?.showAlert(title: "Error", message: "Failed to update default address.")
                }
            }
        }
    }
    
    // MARK: - AddressTblCellDelegate
    
    func addressTblCellDidTapDelete(_ cell: AddressTblCell) {
        guard let indexPath = addressTblView.indexPath(for: cell) else { return }

        // Show confirmation alert
        let alertController = UIAlertController(title: "Delete Address", message: "Are you sure you want to delete this address?", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { [weak self] _ in
            self?.deleteAddress(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }

    /// Deletes an address at a specific indexPath
    private func deleteAddress(at indexPath: IndexPath) {
        // Show loader
        showLoadingIndicator()

        viewModel.deleteAddress(at: indexPath.row) { [weak self] success in
            DispatchQueue.main.async {
                // Hide loader
                self?.hideLoadingIndicator()

                if success {
                    // Remove the row from table view
                    self?.addressTblView.deleteRows(at: [indexPath], with: .automatic)
                    // Check if the deleted address was the selected one
                    if self?.viewModel.selectedAddressId == nil, let firstAddress = self?.viewModel.addresses.first {
                        self?.viewModel.selectedAddressId = firstAddress.id
                        self?.addressTblView.reloadData()
                    }
                } else {
                    self?.showAlert(title: "Error", message: "Failed to delete address.")
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

