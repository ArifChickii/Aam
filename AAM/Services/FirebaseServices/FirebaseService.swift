//
//  FirebaseService.swift
//  AAM
//
//  Created by Arif ww on 25/08/2024.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore

class FirebaseService {
    private var db = Firestore.firestore()
    
    func fetchProducts(completion: @escaping ([Product]) -> Void) {
        db.collection("Products").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                var products: [Product] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    let product = Product(
                        id: document.documentID,
                        images: data["image"] as? [String] ?? [],
                        title: data["title"] as? String ?? "",
                        description: data["description"] as? String ?? "",
                        size: data["size"] as? String ?? "",
                        category: data["category"] as? [String] ?? [],
                        price: data["price"] as? Double ?? 0.0,
                        color: data["color"] as? String ?? "",
                        rating: data["rating"] as? String ?? "0.0",
                        cutPrice: data["cutPrice"] as? Double ?? 0.0
                    )
                    products.append(product)
                }
                completion(products)
            }
        }
    }
    
    
    
    func uploadImage(image: UIImage,imageName: String, completion: @escaping (Result<String, Error>) -> Void) {
        guard let imageData = image.pngData() else {
            completion(.failure(NSError(domain: "InvalidImage", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to convert image to PNG"])))
            return
        }
        
        // Get a reference to the Firebase storage
        let storage = Storage.storage()
        
        // Reference to the folder "uploads/product_images"
        let storageRef = storage.reference().child("uploads/product_images/\(imageName).png")
        
        // Metadata
        let metadata = StorageMetadata()
        metadata.contentType = "image/png"
        
        // Upload the image data
        storageRef.putData(imageData, metadata: metadata) { metadata, error in
            if let error = error {
                completion(.failure(error))  // Upload failed, return error
            } else {
                // Retrieve the download URL after a successful upload
                storageRef.downloadURL { url, error in
                    if let error = error {
                        completion(.failure(error))  // Failed to get download URL
                    } else if let url = url {
                        completion(.success(url.absoluteString))  // Success, return the download URL
                    }
                }
            }
        }
    }
    
    
    
    
    
    
    
    
    func saveProduct(product: Product, completion: @escaping (Result<String, Error>) -> Void) {
        // Get a reference to the 'products' collection
        let productsRef = db.collection("Products")
        
        // Create a new document with an automatically generated ID
        let newProductRef = productsRef.document()
        
        // Set the product's ID to the auto-generated one
        var productWithID = product
        productWithID.id = newProductRef.documentID
        
        do {
            // Convert the Product object to a dictionary
            let productData = try Firestore.Encoder().encode(productWithID)
            
            // Save the product data
            newProductRef.setData(productData) { error in
                if let error = error {
                    completion(.failure(error))  // Return failure if there's an error
                } else {
                    completion(.success(newProductRef.documentID))  // Return the generated document ID
                }
            }
        } catch let error {
            completion(.failure(error))  // Error during encoding
        }
    }
    
    
    
  

        func deleteProduct(withId productId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            // Reference to the 'products' collection
            let productRef = db.collection("Products").document(productId)

            // Attempt to delete the document
            productRef.delete { error in
                if let error = error {
                    completion(.failure(error))  // Return failure if there's an error
                } else {
                    completion(.success(()))  // Success, product deleted
                }
            }
        }
    

    
    
    
}

    



