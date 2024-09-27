//
//  AddProductViewModel.swift
//  AAM
//
//  Created by Mac on 11/09/2024.
//

import Foundation
import UIKit
class AddProductViewModel{
    private let productService: FirebaseService
    var imageLists: [UIImage] = []
    var selectedSize = [DropDown]()
    var selectedFabric = [DropDown]()
    var selectedColor = [DropDown]()
    var selectedCategory  = "Please select Category"
    var selectedPriceValues : PriceModelForPassingBack?
    
    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
        
    }
    
    

    func uploadImagesToFirebase(images: [UIImage], completion: @escaping ([String]) -> Void) {
        let dispatchGroup = DispatchGroup()
        var uploadedImages =  [String]() // Dictionary to store unique names and their URLs

        for image in images {
            let uniqueImageName = UUID().uuidString // Generate a unique image name
            dispatchGroup.enter()

            productService.uploadImage(image: image, imageName: uniqueImageName) { result in
                switch result {
                case .success(let downloadURL):
                    print("Image \(uniqueImageName) uploaded successfully: \(downloadURL)")
                    uploadedImages.append(downloadURL) // Save image name and URL
                case .failure(let error):
                    print("Failed to upload image \(uniqueImageName): \(error.localizedDescription)")
                }
                dispatchGroup.leave()
            }
        }

        // Notify when all images have been uploaded
        dispatchGroup.notify(queue: .main) {
            print("All images uploaded successfully.")
            completion(uploadedImages)  // Return the dictionary of image names and URLs
        }
    }

    
    func addProductToFirebase(){
        
        
        let newProduct = Product(images: ["https://example.com/image.png"], title: "first testing Product", description: "this is testing product for server uploading", size: "Medium", category: ["Women", "Saree"], price: 40.0, color: "Red", rating: "5", cutPrice: 30.0)
        
        
        productService.saveProduct(product: newProduct) { result in
            switch result {
            case .success(let generatedID):
                print("Product saved successfully with ID: \(generatedID)")
            case .failure(let error):
                print("Failed to save product: \(error.localizedDescription)")
            }
        }
        
        
        
    }
    
    
    
    
}
