//
//  ProductBagVC.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit

class ProductBagVC: UIViewController , Storyboarded{
    @IBOutlet weak var productTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
    }
    private func registerCells() {
        productTblView.register(UINib(nibName: ProductBagTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductBagTblCell.identifier)
    }
    
    private func setDelegatesAndDataSources() {
        productTblView.delegate = self
        productTblView.dataSource = self
    }
    @IBAction func backAction(){
        Router.pop(from: self)
    }
    @IBAction func ProceedToCheckout(){
        
    }
   
}
extension ProductBagVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductBagTblCell.identifier, for: indexPath) as? ProductBagTblCell else {
            return UITableViewCell()
        }
        
        return cell
    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 150
    }
    
    
}
