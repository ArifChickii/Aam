//
//  SelectShippingAddressVC.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit


class SelectShippingAddressVC: UIViewController , Storyboarded{
    @IBOutlet weak var addressTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
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
    @IBAction func backAction(){
        Router.pop(from: self)
    }
    @IBAction func continueAction(){
        Router.MoveToSelectPaymentMethod(from: self)
    }
   
}
extension SelectShippingAddressVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AddressTblCell.identifier, for: indexPath) as? AddressTblCell else {
            return UITableViewCell()
        }
        return cell

    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
