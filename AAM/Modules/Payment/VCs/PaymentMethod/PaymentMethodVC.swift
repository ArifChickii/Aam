//
//  PaymentMethodVC.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit



class PaymentMethodVC: UIViewController , Storyboarded{
    @IBOutlet weak var cardTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
    }
    private func registerCells() {
        cardTblView.register(UINib(nibName: MasterCardTblCell.identifier, bundle: nil), forCellReuseIdentifier: MasterCardTblCell.identifier)
        cardTblView.register(UINib(nibName: VisaTblCell.identifier, bundle: nil), forCellReuseIdentifier: VisaTblCell.identifier)
        cardTblView.estimatedRowHeight = 100
        cardTblView.rowHeight = UITableView.automaticDimension
    }
    
    private func setDelegatesAndDataSources() {
        cardTblView.delegate = self
        cardTblView.dataSource = self
    }
    @IBAction func backAction(){
        Router.pop(from: self)
    }
    @IBAction func continueAction(){
        Router.MoveToAddCardInfo(from: self)
    }
   
}
extension PaymentMethodVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: MasterCardTblCell.identifier, for: indexPath) as? MasterCardTblCell else {
                return UITableViewCell()
            }
            return cell
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: VisaTblCell.identifier, for: indexPath) as? VisaTblCell else {
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
