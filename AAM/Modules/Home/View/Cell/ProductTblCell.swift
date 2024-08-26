//
//  ProductTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductTblCell: UITableViewCell {
    static let identifier = "ProductTblCell"
    @IBOutlet weak var collImages: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblCutPrice: UILabel!
    var imagesList = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setupDelegates()
        registerNib()

        pageController.numberOfPages = imagesList.count
        pageController.addTarget(self, action: #selector(pageControlDidChange(_:)), for: .valueChanged)
    }
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    func setupDelegates(){
        
        collImages.dataSource = self
        collImages.delegate = self
    }
    func registerNib(){
        let nib = UINib(nibName: ProductImageCellColl.identifier, bundle: nil)
        collImages.register(nib, forCellWithReuseIdentifier: ProductImageCellColl.identifier)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func configure(obj: Product){
        self.lblTitle.text = obj.title
        self.lblPrice.text = "\(obj.price )"
        self.lblCutPrice.text = "\(obj.cutPrice)"
        self.imagesList = obj.images
        self.collImages.reloadData()
        
    }
    
}
extension ProductTblCell: UICollectionViewDelegate, UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imagesList.count
//        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductImageCellColl.identifier, for: indexPath) as! ProductImageCellColl
                
        cell.configure(imageUrl: imagesList[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 300)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageController.currentPage = Int(pageIndex)
    }
}
