//
//  CheckoutFormVC.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class CheckoutFormVC: UIViewController, Storyboarded {
    var viewModel = ProductFormViewModel()
    @IBOutlet weak var formTblView: UITableView!
    
    // New property to hold the address being edited
    var addressToEdit: ShippingAddress?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup delegates and data sources
        setDelegatesAndDataSources()
        registerCells()
        
        formTblView.estimatedRowHeight = 100
        formTblView.rowHeight = UITableView.automaticDimension
        
        // If editing an address, populate the form fields
        if let address = addressToEdit {
            viewModel.populateFormFields(with: address)
        }
    }
    
    private func registerCells() {
        formTblView.register(UINib(nibName: FormTblCell.identifier, bundle: nil), forCellReuseIdentifier: FormTblCell.identifier)
        formTblView.register(UINib(nibName: CheckBoxLblTblCell.identifier, bundle: nil), forCellReuseIdentifier: CheckBoxLblTblCell.identifier)
    }
    
    private func setDelegatesAndDataSources() {
        formTblView.delegate = self
        formTblView.dataSource = self
    }
    
    @IBAction func backAction() {
        Router.pop(from: self)
    }
    
    @IBAction func continueButtonTapped() {
        // Validate the form
        if validateForm() {
            // Save the address to Firebase
            saveShippingAddress()
        } else {
            // Show alert
            showAlert(title: "Error", message: "Please complete all required fields.")
        }
    }
    
    private func validateForm() -> Bool {
        var isValid = true
        for (index, field) in viewModel.formFields.enumerated() {
            if field.isRequired && (field.value == nil || field.value!.isEmpty) {
                isValid = false
                // Highlight the field
                if let cell = formTblView.cellForRow(at: IndexPath(row: index, section: 0)) as? FormTblCell {
                    cell.setValidationError(true)
                }
            } else {
                // Remove any previous validation error
                if let cell = formTblView.cellForRow(at: IndexPath(row: index, section: 0)) as? FormTblCell {
                    cell.setValidationError(false)
                }
            }
        }
        return isValid
    }
    
    private func saveShippingAddress() {
        // Collect data from viewModel
        let fullName = viewModel.getValueForTitle("Full Name") ?? ""
        let address = viewModel.getValueForTitle("Address") ?? ""
        let flatOrBlockNo = viewModel.getValueForTitle("Flat/Block No") ?? ""
        let postalCode = viewModel.getValueForTitle("Postal / Zipcode") ?? ""
        let country = viewModel.getValueForTitle("Country") ?? ""
        let city = viewModel.getValueForTitle("City") ?? ""
        let makeDefaultAddress = viewModel.getBoolValueForTitle("Make this my default address")
        let sameBillingAddress = viewModel.getBoolValueForTitle("Same billing address")

        // Create or update the ShippingAddress object
        var shippingAddress = ShippingAddress(
            fullName: fullName,
            address: address,
            flatOrBlockNo: flatOrBlockNo,
            postalCode: postalCode,
            country: country,
            city: city,
            makeDefaultAddress: makeDefaultAddress,
            sameBillingAddress: sameBillingAddress
        )
        // If editing, retain the existing address ID
        if let existingAddressId = addressToEdit?.id {
            shippingAddress.id = existingAddressId
        }

        // Show loader if needed
        showLoadingIndicator()

        // Save to Firebase
        let firebaseService = FirebaseService()
        firebaseService.saveShippingAddress(address: shippingAddress) { [weak self] result in
            DispatchQueue.main.async {
                // Hide loader
                self?.hideLoadingIndicator()
                guard let self = self else { return }
                switch result {
                case .success():
                    // Move back to SelectShippingAddressVC
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    // Show error
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
            }
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

extension CheckoutFormVC: UITableViewDelegate, UITableViewDataSource, FormTblCellDelegate, CheckBoxLblTblCellDelegate {
    
    func formTblCell(_ cell: FormTblCell, didUpdateText text: String?) {
        if let indexPath = formTblView.indexPath(for: cell) {
            viewModel.formFields[indexPath.row].value = text
        }
    }
    
    func checkBoxLblTblCell(_ cell: CheckBoxLblTblCell, didChangeValue isChecked: Bool) {
        if let indexPath = formTblView.indexPath(for: cell) {
            viewModel.formFields[indexPath.row].value = isChecked ? "true" : "false"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.formFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let item = self.viewModel.formFields[indexPath.row]
        if item.title == viewModel.makeDefaultAddress || item.title == viewModel.saveBillingAddress {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: CheckBoxLblTblCell.identifier, for: indexPath) as? CheckBoxLblTblCell else {
                return UITableViewCell()
            }
            let isChecked = item.value == "true"
            cell.configure(isChecked: isChecked, title: item.title)
            cell.delegate = self
            return cell
        } else {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FormTblCell.identifier, for: indexPath) as? FormTblCell else {
                return UITableViewCell()
            }
            cell.configure(obj: item)
            cell.delegate = self
            return cell
        }

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

