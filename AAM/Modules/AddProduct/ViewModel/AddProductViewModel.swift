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
    
    private let productService: FirebaseService
    
    // Images that the user picks locally (for upload)
    // If we are editing, we may also download old images to show in the UI
    var imageLists: [UIImage] = []
    
    // Multi-select fields
    var selectedSize    = [String]()
    var selectedFabric  = [String]()
    var selectedColor   = [String]()
    
    // Category
    var selectedCategory: ProductCategory?
    
    // Price
    var selectedPriceValues: PriceModelForPassingBack?
    
    // Title / Description
    var selectedTitle = ""
    var selectedDesc  = ""
    
    // Validation flags
    var isTitleFieldFilled       = true
    var isDescFieldFilled        = true
    var showRedBorderOnCategory  = false
    var showRedBorderOnAddImage  = false
    var showRedBorderOnSize      = false
    var showRedBorderOnColor     = false
    var showRedBorderOnFabric    = false
    var showRedBorderOnPrice     = false
    
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
    
    // MARK: - Uploading Images
    /// Uploads each provided `UIImage` to Firebase Storage, returning their public URLs.
    func uploadImagesToFirebase(images: [UIImage], completion: @escaping ([String]) -> Void) {
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
    
    // MARK: - Create Product
    /// Creates a new `ProductInfo` from the currently filled view-model fields.
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
            createdAt: "",
            status: "active"
        )
        
        return newProduct
    }
    
    /// Saves the newly created product to Firestore
    func addProductToFirebase(productObj: ProductInfo, completion: @escaping (String) -> Void) {
        productService.saveProductInfo(product: productObj) { result in
            switch result {
            case .success(let generatedID):
                print("Product saved successfully with ID: \(generatedID)")
                completion(generatedID)
            case .failure(let error):
                print("Failed to save product: \(error.localizedDescription)")
                completion("Failed to save product: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Update Existing Product
    /// Updates an existing product doc in Firestore
    func updateProductInFirebase(productObj: ProductInfo, completion: @escaping (String) -> Void) {
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

