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
    private let productViewModel = ProductsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
        productViewModel.fetchProducts {
                    // Additional actions after fetching products
                    DispatchQueue.main.async {
                        self.productTblView.reloadData()
                    }
                }
        

        fetchAllCategoriesAndLists()
        
        
    }
    
    func fetchAllCategoriesAndLists(){
        productViewModel.fetchCategories {
            print("do nothing")
        }
        productViewModel.fetchAllSizes()
        productViewModel.fetchAllColors()
        productViewModel.fetchAllFabrics()
        
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
extension HomeVC: UITableViewDelegate, UITableViewDataSource, CollectionViewCellDidSelectDelegate{
    func collectionViewCellDidSelectItem(at indexPath: IndexPath, in tableViewCell: UITableViewCell) {
        if let tableViewIndexPath = productTblView.indexPath(for: tableViewCell) {
                    print("Selected item at collectionView indexPath: \(indexPath) inside tableView cell at indexPath: \(tableViewIndexPath)")
                    // Perform your action here
            Router.MoveToProductDetail(from: self, product: self.productViewModel.product(at: tableViewIndexPath.row))
                }
        
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return productViewModel.numberOfProducts()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ProductTblCell.identifier, for: indexPath) as! ProductTblCell
        cell.delegate = self
        cell.configure(obj: self.productViewModel.product(at: indexPath.row))
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.row == 0{
            Router.MoveToAddProduct(from: self)
        }else{
            Router.MoveToProductDetail(from: self, product: self.productViewModel.product(at: indexPath.row))
        }
        
    }
    
}
