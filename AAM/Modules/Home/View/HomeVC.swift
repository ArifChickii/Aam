//
//  HomeVC.swift
//  AAM
//
//  Created by Arif ww on 08/08/2024.
//

import UIKit

class HomeVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var productTblView: UITableView!
    private let viewModel = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
    }
    
    
    func setDelegatesAndDataSources(){
        
        productTblView.delegate = self
        productTblView.dataSource = self
    }
    
    private func registerCells() {
        
        
        productTblView.register(UINib(nibName: ProductTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductTblCell.identifier)
        
    }

    @IBAction func backAction(){
        Router.pop(from: self)
    }
}

// MARK: UITableView
extension HomeVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.courseList.count
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTblCell.identifier, for: indexPath) as! ProductTblCell
//        cell.configure(obj: self.viewModel.courseList[indexPath.row])
        
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        Router.MoveToProductDetail(from: self)
    }
    
}
