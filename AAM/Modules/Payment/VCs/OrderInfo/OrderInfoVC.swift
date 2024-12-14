//
//  OrderInfoVC.swift
//  AAM
//
//  Created by Arif on 07/11/2024.
//

import UIKit


class OrderInfoVC: UIViewController , Storyboarded{
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
    @IBAction func continueAction(){
        Router.showSuccessDialog(from: self)
    }
   
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
