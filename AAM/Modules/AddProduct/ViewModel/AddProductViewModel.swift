//
//  AddProductViewModel.swift
//  AAM
//
//  Created by Mac on 11/09/2024.
//

import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestoreInternal

class AddProductViewModel {
    private let productService: FirebaseService
    var imageLists: [UIImage] = []
    var selectedSize = [String]()
    var selectedFabric = [String]()
    var selectedColor = [String]()
    var selectedCategory: ProductCategory?
    var selectedPriceValues: PriceModelForPassingBack?
    var selectedTitle = ""
    var selectedDesc = ""
    var isTitleFieldFilled = true
    var isDescFieldFilled = true
    var showRedBorderOnCategory = false
    var showRedBorderOnAddImage = false
    var showRedBorderOnSize = false
    var showRedBorderOnColor = false
    var showRedBorderOnFabric = false
    var showRedBorderOnPrice = false
    
    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
    }
    
    func uploadImagesToFirebase(images: [UIImage], completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var uploadedImages = [String]() // To store image URLs
        
        for image in images {
            let uniqueImageName = UUID().uuidString // Generate a unique image name
            dispatchGroup.enter()
            
            productService.uploadImage(image: image, imageName: uniqueImageName) { result in
                switch result {
                case .success(let downloadURL):
                    print("Image \(uniqueImageName) uploaded successfully: \(downloadURL)")
                    uploadedImages.append(downloadURL) // Save image URL
                case .failure(let error):
                    print("Failed to upload image \(uniqueImageName): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }
        
        // Notify when all images have been uploaded
        dispatchGroup.notify(queue: .main) {
            print("All images uploaded successfully.")
            completion(uploadedImages)
        }
    }
    
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
    
    func createProductInfo(with imageURLs: [String]) -> ProductInfo? {
        guard let currentUser = Auth.auth().currentUser else {
            print("❌ User not logged in.")
            return nil
        }
        
        let newProduct = ProductInfo(
            id: nil, // Will be set by FirebaseService
            sellerId: currentUser.uid,
            images: imageURLs,
            sizes: selectedSize,
            colors: selectedColor,
            fabrics: selectedFabric,
            category: selectedCategory,
            title: selectedTitle,// Will be set by FirebaseService
            description: selectedDesc,
            price: selectedPriceValues?.price,
            rating: "0.0", // Default rating
            cutPrice: selectedPriceValues?.cutPrice,
            createdAt: "", status: "active"
        )
        
        return newProduct
    }
}



