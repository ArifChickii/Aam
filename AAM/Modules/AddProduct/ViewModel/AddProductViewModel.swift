//
//  AddProductViewModel.swift
//  AAM
//
//  Created by Mac on 11/09/2024.
//

import Foundation
import UIKit
import FirebaseAuth
import SDWebImage



class AddProductViewModel {
    
    // MARK: - Dependencies
    private let productService: FirebaseService
    
    // MARK: - Data for Creating/Editing
    /// Locally picked images (for upload)
    var imageLists: [UIImage] = []
    
    /// Multi-select fields
    var selectedSize    = [String]()
    var selectedFabric  = [String]()
    var selectedColor   = [String]()
    
    /// Category
    var selectedCategory: ProductCategory?
    
    /// Price
    var selectedPriceValues: PriceModelForPassingBack?
    
    /// Title & Description
    var selectedTitle = ""
    var selectedDesc  = ""
    
    // MARK: - Validation flags
    var isTitleFieldFilled       = true
    var isDescFieldFilled        = true
    var showRedBorderOnCategory  = false
    var showRedBorderOnAddImage  = false
    var showRedBorderOnSize      = false
    var showRedBorderOnColor     = false
    var showRedBorderOnFabric    = false
    var showRedBorderOnPrice     = false
    
    // MARK: - Init
    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
    }
    
    // MARK: - Edit Mode Setup
    /// Loads existing product data into the view model for editing.
    /// Also downloads the old images asynchronously (if any),
    /// then calls `completion()` on the main thread so the VC can reload.
    func setupEditMode(with product: ProductInfo, completion: @escaping () -> Void) {
        // 1) Fill text fields
        self.selectedTitle = product.title ?? ""
        self.selectedDesc  = product.description ?? ""
        
        // 2) Fill multi-select
        self.selectedSize   = product.sizes ?? []
        self.selectedFabric = product.fabrics ?? []
        self.selectedColor  = product.colors ?? []
        
        // 3) Fill category
        self.selectedCategory = product.category
        
        // 4) Fill price
        if let p = product.price, let cp = product.cutPrice {
            self.selectedPriceValues = PriceModelForPassingBack(price: p, cutPrice: cp)
        }
        
        // 5) Download old images from product.images
        guard let urlStrings = product.images, !urlStrings.isEmpty else {
            // No images? Just call completion
            completion()
            return
        }
        
        let group = DispatchGroup()
        
        for urlString in urlStrings {
            if let url = URL(string: urlString) {
                group.enter()
                SDWebImageDownloader.shared.downloadImage(with: url, options: [], progress: nil) { [weak self] image, _, error, _ in
                    defer { group.leave() }
                    guard let self = self else { return }
                    if let downloadedImage = image, error == nil {
                        self.imageLists.append(downloadedImage)
                    }
                }
            }
        }
        
        group.notify(queue: .main) {
            // Now all old images (if any) are appended
            completion()
        }
    }
    
    // MARK: - Upload Images
    /// Uploads each provided `UIImage` to Firebase Storage, returning their public URLs.
    func uploadImagesToFirebase(images: [UIImage],
                                completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var uploadedImages = [String]()
        
        for image in images {
            let uniqueImageName = UUID().uuidString
            dispatchGroup.enter()
            
            productService.uploadImage(image: image, imageName: uniqueImageName) { result in
                switch result {
                case .success(let downloadURL):
                    print("Image \(uniqueImageName) uploaded successfully: \(downloadURL)")
                    uploadedImages.append(downloadURL)
                case .failure(let error):
                    print("Failed to upload image \(uniqueImageName): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            print("All images uploaded successfully.")
            completion(uploadedImages)
        }
    }
    
    // MARK: - Create Product Info
    /// Assembles a new `ProductInfo` from the currently filled fields (in create mode).
    func createProductInfo(with imageURLs: [String]) -> ProductInfo? {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ User not logged in.")
            return nil
        }
        
        let newProduct = ProductInfo(
            id: nil,
            sellerId: currentUser.uid,
            images: imageURLs,
            sizes: selectedSize,
            colors: selectedColor,
            fabrics: selectedFabric,
            category: selectedCategory,
            title: selectedTitle,
            description: selectedDesc,
            price: selectedPriceValues?.price,
            rating: "0.0",
            cutPrice: selectedPriceValues?.cutPrice,
            owner_infor: nil, 
            createdAt: "",
            status: "active"
        )
        
        return newProduct
    }
    
    // MARK: - Save New Product (Creating)
    /// Saves a newly created product to Firestore (status=active, increments activeCount).
    func addProductToFirebase(productObj: ProductInfo,
                              completion: @escaping (Result<String, Error>) -> Void) {
        productService.saveProductInfo(product: productObj, completion: completion)
    }
    
    // MARK: - Update Existing Product
    /// Updates an existing product doc in Firestore
    func updateProductInFirebase(productObj: ProductInfo,
                                 completion: @escaping (String) -> Void) {
        productService.updateProductInfo(product: productObj) { result in
            switch result {
            case .success():
                completion("Product updated successfully!")
            case .failure(let error):
                completion("Failed to update product: \(error.localizedDescription)")
            }
        }
    }
}

