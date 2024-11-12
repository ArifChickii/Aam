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
            self?.hideActivityIndicator()
        }
        
        viewModel.onError = { [weak self] errorMessage in
            self?.hideActivityIndicator()
            self?.showAlert(title: "Error", message: errorMessage)
        }
    }
    
    private func fetchShippingAddresses() {
        // Show loader
        showActivityIndicator()
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
    
    private func showActivityIndicator() {
        // Implement your loader here
    }
    
    private func hideActivityIndicator() {
        // Hide your loader here
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

extension SelectShippingAddressVC: UITableViewDelegate, UITableViewDataSource {
    
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
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Update selection
        viewModel.selectAddress(at: indexPath.row)
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

