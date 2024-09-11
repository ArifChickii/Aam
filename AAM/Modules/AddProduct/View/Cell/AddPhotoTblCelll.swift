//
//  AddPhotoTblCelll.swift
//  AAM
//
//  Created by Mac on 02/09/2024.
//

import UIKit

class AddPhotoTblCelll: UITableViewCell, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    static let identifier = "AddPhotoTblCelll"
    @IBOutlet weak var collImages: UICollectionView!
    var images: [UIImage] = []
        var onAddImageTapped: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupDelegates()
        registerNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setupDelegates(){
        
        collImages.dataSource = self
        collImages.delegate = self
        
    }
    
    
    func registerNib(){
        let nib = UINib(nibName: PickPhotoCollCell.identifier, bundle: nil)
        collImages.register(nib, forCellWithReuseIdentifier: PickPhotoCollCell.identifier)
    }
    func configure(images: [UIImage]){
        self.images = images
        self.collImages.reloadData()
    }
    
}


extension AddPhotoTblCelll: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count + 1
//        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
       
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PickPhotoCollCell.identifier, for: indexPath) as! PickPhotoCollCell
        
//        cell.configure(imageUrl: imagesList[indexPath.item])
        if indexPath.item == images.count {
                    // Add Image cell
                    cell.imgAdded.isHidden = true
                    cell.imgAdd.isHidden = false
                   
                } else {
                    // Display selected image
                    cell.imgAdded.image = images[indexPath.item]
                    cell.imgAdded.isHidden = false
                    cell.imgAdd.isHidden = true
                    
                }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        open pick view 
        onAddImageTapped?()
    }
    
}
