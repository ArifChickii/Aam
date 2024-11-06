//
//  OrderInfoVC.swift
//  AAM
//
//  Created by Arif on 07/11/2024.
//

import UIKit


class OrderInfoVC: UIViewController , Storyboarded{
    @IBOutlet weak var orderTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: OrderInfoTblCell.identifier, for: indexPath) as? OrderInfoTblCell else {
                return UITableViewCell()
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: AdditionalInfoTblCell.identifier, for: indexPath) as? AdditionalInfoTblCell else {
                return UITableViewCell()
            }
            return cell
        default:
            return UITableViewCell()
        }
        

    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
