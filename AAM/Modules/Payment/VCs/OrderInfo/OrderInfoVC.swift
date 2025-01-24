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


class OrderInfoVC: UIViewController , Storyboarded{
    private var paymentSheet: PaymentSheet?
        private let paymentService = PaymentService()
    var buyerStripeCustomerId: String = "cus_RcfJFHqiAOr8Te"
       var sellerStripeMerchantId: String = "acct_1QjPiyEAtAOsS0Qb"
    @IBOutlet weak var orderTblView: UITableView!
    var viewModel: OrderInfoViewModel!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        assert(viewModel != nil, "OrderInfoViewModel should not be nil")
        setDelegatesAndDataSources()
        registerCells()
    }
    private func registerCells() {
        orderTblView.register(UINib(nibName: OrderInfoTblCell.identifier, bundle: nil), forCellReuseIdentifier: OrderInfoTblCell.identifier)
        orderTblView.register(UINib(nibName: AdditionalInfoTblCell.identifier, bundle: nil), forCellReuseIdentifier: AdditionalInfoTblCell.identifier)
        orderTblView.estimatedRowHeight = 200
        orderTblView.rowHeight = UITableView.automaticDimension
    }
    
    private func setDelegatesAndDataSources() {
        orderTblView.delegate = self
        orderTblView.dataSource = self
    }
    @IBAction func backAction(){
        Router.pop(from: self)
    }
    @IBAction func continueAction() {
        // 1) Calculate total price in your smallest currency unit (e.g. cents)
        let order = viewModel.createOrder()
        //
        
        // 2) Make sure you have buyerStripeCustomerId and sellerStripeMerchantId
        guard !buyerStripeCustomerId.isEmpty, !sellerStripeMerchantId.isEmpty else {
            showAlert("Missing IDs", message: "Stripe Customer or Merchant ID not set.")
            return
        }
        
        // 3) Call create-payment-intent
        paymentService.createPaymentIntent(amount: Int(order.grandTotal),
                                           currency: "usd",
                                           customerId: buyerStripeCustomerId,
                                           merchantId: sellerStripeMerchantId,
                                           paymentMethod: nil) { [weak self] result in
            switch result {
            case .success(let response):
                // response.clientSecret -> pi_XXX_secret_YYY
                DispatchQueue.main.async {
                    self?.setupPaymentSheet(clientSecret: response.clientSecret)
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self?.showAlert("Error", message: error.localizedDescription)
                }
            }
        }
    }
    
    private func calculateCartTotalInCents(bagProducts: [BagProduct]) -> Int {
        // Example: sum up product price * quantity * 100
        var totalCents = 0
        for item in bagProducts {
            let price = Double(item.product.price ?? "0") ?? 0
            totalCents += Int(price * 100) * item.count
        }
        // Possibly add tax, shipping
        totalCents += 500 // $5 tax in cents
        totalCents += 1000 // $10 shipping in cents
        return totalCents
    }
    
    private func showAlert(_ title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    private func setupPaymentSheet(clientSecret: String) {
        var configuration = PaymentSheet.Configuration()
        configuration.merchantDisplayName = "Aam"
        // If you'd like to allow Apple Pay, you'd configure it here:
        // configuration.applePay = .init(
        //     merchantId: "your.apple.pay.merchant.id",
        //     merchantCountryCode: "US"
        // )
        
        // PaymentSheet automatically shows a card field, processes payment, etc.
        paymentSheet = PaymentSheet(paymentIntentClientSecret: clientSecret,
                                    configuration: configuration)
        
        // 4) Present the PaymentSheet
        presentPaymentSheet()
    }
    
    private func presentPaymentSheet() {
        paymentSheet?.present(from: self) { paymentResult in
            switch paymentResult {
            case .completed:
                // The PaymentIntent is now in "requires_capture"
                // Funds are held in escrow
                self.showAlert("Payment Authorized", message: "The payment is authorized and funds are in escrow.")
                // Optionally, you can now create your Order in Firestore, or do anything else you need.
                
            case .canceled:
                self.showAlert("Payment Canceled", message: "User canceled payment.")
                
            case .failed(let error):
                self.showAlert("Payment Failed", message: error.localizedDescription)
            }
        }
    }
    
//    @IBAction func continueAction(){
//        self.showLoadingIndicator()
//        // 1. Create the order from the viewModel
//        let order = viewModel.createOrder()
//        
//        // 2. Save the order to Firebase
//        let firebaseService = FirebaseService()
//        firebaseService.saveOrder(order: order) { [weak self] result in
//            switch result {
//        
//            case .success(let orderId):
//                // Order saved successfully with ID: orderId
//                // Here we can show a success dialog to the user.
//                // For now we just call the Router as original code suggests.
//                DispatchQueue.main.async {
//                    self?.hideLoadingIndicator()
//                    // Show success dialog
//                    Router.showSuccessDialog(from: self!)
//                }
//                
//            case .failure(let error):
//                // Handle error saving order
//                DispatchQueue.main.async {
//                    self?.hideLoadingIndicator()
//                    let alert = UIAlertController(title: "Error", message: "Failed to place order: \(error.localizedDescription)", preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default))
//                    self?.present(alert, animated: true, completion: nil)
//                }
//            }
//        }
//    }
   
}
extension OrderInfoVC: UITableViewDelegate, UITableViewDataSource {
  
    
    
    
    
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            // Product cells
            let cell = tableView.dequeueReusableCell(withIdentifier: OrderInfoTblCell.identifier, for: indexPath) as! OrderInfoTblCell
            let bagProduct = viewModel.bagProducts[indexPath.row]
            let isLastProduct = indexPath.row == viewModel.bagProducts.count - 1
            cell.configure(with: bagProduct, showTotal: isLastProduct, totalPrice: viewModel.grandTotal, tax: viewModel.tax, shippingCost: viewModel.shippingCost)
            return cell
        } else {
            // Address cell
            let cell = tableView.dequeueReusableCell(withIdentifier: AdditionalInfoTblCell.identifier, for: indexPath) as! AdditionalInfoTblCell
            cell.configure(with: viewModel.selectedAddress)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}
