//
//  ProductCategoryTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductCategoryTblCell: UITableViewCell {
    static let identifier = "ProductCategoryTblCell"
    @IBOutlet weak var categoryCollView: UICollectionView!
    var categoriesList = [String]()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        categoryCollView.delegate = self
        categoryCollView.dataSource = self
        registerCells()
    }
    private func registerCells() {
        categoryCollView.register(UINib(nibName: ProductCategoryTitleCollCell.identifier, bundle: nil), forCellWithReuseIdentifier: ProductCategoryTitleCollCell.identifier)
        
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func configure(obj: ProductInfo){
        self.categoriesList = obj.category?.subCategories ?? []
        
        self.categoryCollView.reloadData()
    }
    
}


extension ProductCategoryTblCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesList.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if  let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCategoryTitleCollCell.identifier, for: indexPath) as? ProductCategoryTitleCollCell{
            cell.configure(title: categoriesList[indexPath.item])
            return cell
        }else{
            return UICollectionViewCell()
        }
        
    }
    
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch indexPath.item {
//        case 0:
//            Router.showDashboard(from: self)
//        default:
//            Router.showSampleVC(from: self)
//        }
//    }
    

    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.size.width / 3.3
        return CGSize(width: width, height: 40)
    }
    
}
