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
    var selectedSize = "Please select size"
    var selectedFabric = "Please select fabric"
    var selectedColor = "Please select color"
    var selectedCategory = "Please select category"
    
    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
    }
    
    
    func uploadImageToFirebase(){
        if let image = UIImage(named: "dummy") {  // Use your image here
            productService.uploadImage(image: image, imageName: "dummy") { result in
                switch result {
                case .success(let downloadURL):
                    print("Image uploaded successfully: \(downloadURL)")
                case .failure(let error):
                    print("Failed to upload image: \(error.localizedDescription)")
                }
            }
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
