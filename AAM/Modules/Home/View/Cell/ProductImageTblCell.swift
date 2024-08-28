//
//  ProductImageTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

class ProductImageTblCell: UITableViewCell {
    static let identifier = "ProductImageTblCell"
    @IBOutlet weak var img: UIImageView!
    @IBOutlet weak var collImages: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    var imagesList = [String]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.selectionStyle = .none
        setupDelegates()
        registerNib()
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
    func configure(obj: Product){
        
        self.imagesList = obj.images ?? []
        pageController.numberOfPages = imagesList.count
        self.collImages.reloadData()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    
}
extension ProductImageTblCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
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
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageController.currentPage = Int(pageIndex)
    }
}
