//
//  OrderInfoVC.swift
//  AAM
//
//  Created by Arif on 07/11/2024.
//

import UIKit
import StripePayments
import StripePaymentSheet
import StripePaymentsUI
import StripeCore

class OrderInfoVC: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet weak var orderTblView: UITableView!
    
    // MARK: - Properties
    var viewModel: OrderInfoViewModel!
    
    private var paymentSheet: PaymentSheet?
    private let paymentService = PaymentService()
    
    // Hard-coded test values:
    var buyerStripeCustomerId: String   = "cus_RcfJFHqiAOr8Te"
    var sellerStripeMerchantId: String  = "acct_1QjPiyEAtAOsS0Qb"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Ensure the viewModel is set before using
        assert(viewModel != nil, "OrderInfoViewModel should not be nil")
        
        setDelegatesAndDataSources()
        registerCells()
    }
    
    // MARK: - Setup
    private func registerCells() {
        orderTblView.register(UINib(nibName: OrderInfoTblCell.identifier, bundle: nil),
                              forCellReuseIdentifier: OrderInfoTblCell.identifier)
        orderTblView.register(UINib(nibName: AdditionalInfoTblCell.identifier, bundle: nil),
                              forCellReuseIdentifier: AdditionalInfoTblCell.identifier)
        orderTblView.estimatedRowHeight = 200
        orderTblView.rowHeight          = UITableView.automaticDimension
    }
    
    private func setDelegatesAndDataSources() {
        orderTblView.delegate   = self
        orderTblView.dataSource = self
    }
    
    // MARK: - Navigation
    @IBAction func backAction() {
        Router.pop(from: self)
    }
    
    // MARK: - Test Mark All as Sold
    /// Example button to test "mark all products as sold" inside this order
    @IBAction func continueAction() {
        viewModel.markAllProductsAsSold { [weak self] result in
            switch result {
            case .success():
                DispatchQueue.main.async {
                    self?.showAlert("Success", message: "All products are sold successfully!")
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert("Error", message: "Failed to mark products as sold: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - Payment Flow
//    @IBAction func continueAction() {
//        // 1) Create the order
//        let order = viewModel.createOrder()
//        
//        // 2) Ensure we have buyerStripeCustomerId & sellerStripeMerchantId
//        guard !buyerStripeCustomerId.isEmpty, !sellerStripeMerchantId.isEmpty else {
//            showAlert("Missing IDs", message: "Stripe Customer or Merchant ID not set.")
//            return
//        }
//        
//        // 3) Create PaymentIntent
//        paymentService.createPaymentIntent(amount: Int(order.grandTotal),
//                                           currency: "usd",
//                                           customerId: buyerStripeCustomerId,
//                                           merchantId: sellerStripeMerchantId,
//                                           paymentMethod: nil) { [weak self] result in
//            switch result {
//            case .success(let response):
//                DispatchQueue.main.async {
//                    self?.setupPaymentSheet(clientSecret: response.clientSecret)
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self?.showAlert("Error", message: error.localizedDescription)
//                }
//            }
//        }
//    }
    
    private func setupPaymentSheet(clientSecret: String) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Aam"
        
        // Apple Pay config if desired:
        // configuration.applePay = .init(
        //   merchantId: "your.apple.pay.merchant.id",
        //   merchantCountryCode: "US"
        // )
        
        // Create PaymentSheet object
        paymentSheet = PaymentSheet(
            paymentIntentClientSecret: clientSecret,
            configuration: configuration
        )
        
        presentPaymentSheet()
    }
    
    private func presentPaymentSheet() {
        paymentSheet?.present(from: self) { paymentResult in
            switch paymentResult {
            case .completed:
                // Payment authorized, funds in escrow
                self.showAlert("Payment Authorized", message: "Funds in escrow.")
                // Optionally, create the Order in Firestore, show success, etc.
                
            case .canceled:
                self.showAlert("Payment Canceled", message: "User canceled payment.")
                
            case .failed(let error):
                self.showAlert("Payment Failed", message: error.localizedDescription)
            }
        }
    }
    
    // MARK: - Helpers
    private func showAlert(_ title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension OrderInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            // Product rows
            let cell = tableView.dequeueReusableCell(
                withIdentifier: OrderInfoTblCell.identifier,
                for: indexPath
            ) as! OrderInfoTblCell
            
            let bagProduct     = viewModel.bagProducts[indexPath.row]
            let isLastProduct  = (indexPath.row == viewModel.bagProducts.count - 1)
            
            cell.configure(
                with: bagProduct,
                showTotal: isLastProduct,
                totalPrice: viewModel.grandTotal,
                tax: viewModel.tax,
                shippingCost: viewModel.shippingCost
            )
            
            return cell
            
        } else {
            // Address row
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AdditionalInfoTblCell.identifier,
                for: indexPath
            ) as! AdditionalInfoTblCell
            
            cell.configure(with: viewModel.selectedAddress)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
}

