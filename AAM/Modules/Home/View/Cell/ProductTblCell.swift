//
//  ProductTblCell.swift
//  AAM
//
//  Created by Arif ww on 20/08/2024.
//

import UIKit

/// For the cell to notify a parent (like HomeVC) that the like button was tapped
protocol ProductTblCellDelegate: AnyObject {
    func didTapLikeButton(in cell: ProductTblCell)
}

protocol CollectionViewCellDidSelectDelegate: AnyObject {
    func collectionViewCellDidSelectItem(at indexPath: IndexPath, in tableViewCell: UITableViewCell)
}

class ProductTblCell: UITableViewCell {
    static let identifier = "ProductTblCell"
    
    // MARK: - Outlets
    @IBOutlet weak var collImages: UICollectionView!
    @IBOutlet weak var pageController: UIPageControl!
    @IBOutlet weak var btnLike: UIButton!
    @IBOutlet weak var imgLike: UIImageView!   // Make sure this is connected in storyboard
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblCutPrice: UILabel!
    
    // MARK: - Delegates
    weak var delegate: CollectionViewCellDidSelectDelegate?      // for the collection view inside the cell
    weak var productCellDelegate: ProductTblCellDelegate?        // for the like button
    
    // MARK: - Properties
    var imagesList = [String]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupDelegates()
        registerNib()
        
        pageController.addTarget(self,
                                 action: #selector(pageControlDidChange(_:)),
                                 for: .valueChanged)
    }
    
    private func setupDelegates() {
        collImages.dataSource = self
        collImages.delegate   = self
    }
    
    private func registerNib() {
        let nib = UINib(nibName: ProductImageCellColl.identifier, bundle: nil)
        collImages.register(nib, forCellWithReuseIdentifier: ProductImageCellColl.identifier)
    }
    
    @objc private func pageControlDidChange(_ sender: UIPageControl) {
        let indexPath = IndexPath(item: sender.currentPage, section: 0)
        collImages.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
    }
    
    // MARK: - Configuration
    
    /// Configures the cell with product info AND whether it’s favorited.
    func configure(obj: ProductInfo, isFavorite: Bool) {
        lblTitle.text     = obj.title
        lblPrice.text     = obj.price ?? "0.0"
        lblCutPrice.text  = obj.cutPrice ?? "0.0"
        
        imagesList = obj.images ?? []
        pageController.numberOfPages = imagesList.count
        collImages.reloadData()
        
        setLikeIcon(isFavorite: isFavorite)
    }
    
    /// Sets the like image to ic_liked or ic_like
    func setLikeIcon(isFavorite: Bool) {
        if isFavorite {
            imgLike.image = UIImage(named: "ic_liked")
        } else {
            imgLike.image = UIImage(named: "ic_like")
        }
    }
    
    // MARK: - Actions
    
    @IBAction func likeButtonTapped(_ sender: UIButton) {
        // Notify parent that the user tapped "like"
        productCellDelegate?.didTapLikeButton(in: self)
    }
}

// MARK: - CollectionView
extension ProductTblCell: UICollectionViewDelegate,
                          UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout
{
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        imagesList.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ProductImageCellColl.identifier,
            for: indexPath
        ) as! ProductImageCellColl
        
        cell.configure(imageUrl: imagesList[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x / scrollView.frame.size.width)
        pageController.currentPage = Int(pageIndex)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        delegate?.collectionViewCellDidSelectItem(at: indexPath, in: self)
    }
}

