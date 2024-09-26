//
//  ProductDetailVC.swift
//  AAM
//
//  Created by Arif ww on 21/08/2024.
//

import UIKit

class ProductDetailVC: UIViewController, Storyboarded {
    var viewModel : ProductDetailViewModel!
    var productDetailObj : Product!
    @IBOutlet weak var productTblView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
    }
    override func viewWillAppear(_ animated: Bool) {
        if let product = productDetailObj{
            viewModel = ProductDetailViewModel(product: product)
            self.productTblView.reloadData()
        }
        
    }
    
    
    func setDelegatesAndDataSources(){
        
        productTblView.delegate = self
        productTblView.dataSource = self
    }
    
    private func registerCells() {
        
        productTblView.register(UINib(nibName: ProductImageTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductImageTblCell.identifier)
//        price part
        productTblView.register(UINib(nibName: ProductPriceAndTitleTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductPriceAndTitleTblCell.identifier)
        //        description part
        productTblView.register(UINib(nibName: ProductDescriptionTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductDescriptionTblCell.identifier)
        //        size and color part
        productTblView.register(UINib(nibName: ProductSizeTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductSizeTblCell.identifier)
        //        add to bag part
        productTblView.register(UINib(nibName: ProductAddToBagTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductAddToBagTblCell.identifier)
        //        categories part
        productTblView.register(UINib(nibName: ProductCategoryTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductCategoryTblCell.identifier)
        //        product rating  part
        productTblView.register(UINib(nibName: ProductRatingTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductRatingTblCell.identifier)
        
        productTblView.estimatedRowHeight = 80
        productTblView.rowHeight = UITableView.automaticDimension
    }

    @IBAction func backAction(){
        Router.pop(from: self)
    }

}

// MARK: UITableView
extension ProductDetailVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.courseList.count
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductImageTblCell.identifier, for: indexPath) as! ProductImageTblCell
            cell.configure(obj: viewModel.product)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductPriceAndTitleTblCell.identifier, for: indexPath) as! ProductPriceAndTitleTblCell
            cell.configure(obj: viewModel.product)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductDescriptionTblCell.identifier, for: indexPath) as! ProductDescriptionTblCell
            cell.configure(obj: viewModel.product)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductSizeTblCell.identifier, for: indexPath) as! ProductSizeTblCell
            cell.configure(obj: viewModel.product)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductAddToBagTblCell.identifier, for: indexPath) as! ProductAddToBagTblCell
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductCategoryTblCell.identifier, for: indexPath) as! ProductCategoryTblCell
            cell.configure(obj: viewModel.product)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductRatingTblCell.identifier, for: indexPath) as! ProductRatingTblCell
            cell.configure(obj: viewModel.product)
            return cell
        default:
            return UITableViewCell()
        }
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 400
        case 1:
            return UITableView.automaticDimension
        case 2:
            return UITableView.automaticDimension
        case 3:
            return UITableView.automaticDimension
        case 4:
            return 50
        case 5:
            return 100
        case 6:
            return 60
        default:
            return 0
        }
    
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        Router.showCourseDetail(from: self, courseObj: self.viewModel.courseList[indexPath.row])
    }
    
}
