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
    
//    func fetchProducts(completion: @escaping ([Product]) -> Void) {
//        db.collection("Products").getDocuments { (querySnapshot, error) in
//            if let error = error {
//                print("Error getting documents: \(error)")
//                completion([])
//            } else {
//                var products: [Product] = []
//                for document in querySnapshot!.documents {
//                    let data = document.data()
//                    let product = Product(
//                        id: document.documentID,
//                        images: data["image"] as? [String] ?? [],
//                        title: data["title"] as? String ?? "",
//                        description: data["description"] as? String ?? "",
//                        size: data["size"] as? String ?? "",
//                        category: data["category"] as? [String] ?? [],
//                        price: data["price"] as? Double ?? 0.0,
//                        color: data["color"] as? String ?? "",
//                        rating: data["rating"] as? String ?? "0.0",
//                        cutPrice: data["cutPrice"] as? Double ?? 0.0
//                    )
//                    products.append(product)
//                }
//                completion(products)
//            }
//        }
//    }
    
    func fetchProducts(completion: @escaping ([ProductInfo]) -> Void) {
        db.collection("Products").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                var products: [ProductInfo] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    // Parse the category dictionary safely
                    if let productCatDic = data["category"] as? [String: Any] {
                        let productCat = ProductCategory(
                            title: productCatDic["title"] as? String ?? "",
                            subCategories: productCatDic["subCategories"] as? [String] ?? []
                        )
                        
                        let product = ProductInfo(
                            id: document.documentID,
                            images: data["images"] as? [String] ?? [],
                            sizes: data["sizes"] as? [String] ?? [],
                            colors: data["colors"] as? [String] ?? [],
                            fabrics: data["fabrics"] as? [String] ?? [],
                            category: productCat,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "",
                            price: data["price"] as? String ?? "",
                            rating: data["rating"] as? String ?? "0.0",
                            cutPrice: data["cutPrice"] as? String ?? ""
                        )
                        
                        products.append(product)
                    } else {
                        print("Error parsing category for document ID: \(document.documentID)")
                    }
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
    
    
    
    func saveProductInfo(product: ProductInfo, completion: @escaping (Result<String, Error>) -> Void) {
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
    

    func fetchCategories(completion: @escaping ([ProductCategoryForDataRecieving]) -> Void) {
        // Reference to the categories collection
        let categoriesRef = db.collection("cats")
        
        // Fetch all documents in the categories collection
        categoriesRef.getDocuments { (snapshot, error) in
            var categoriesData: [ProductCategoryForDataRecieving] = []
            
            if let error = error {
                print("Error fetching categories: \(error.localizedDescription)")
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    let categoryName = document.data()["name"] as? String ?? ""
                    let subcategories = document.data()["subcats"] as? [String] ?? []
                    var subcategoriesDropDownList = [DropDown]()
                    for subcategory in subcategories {
                        let dropDownObj = DropDown(title: subcategory, isChecked: false)
                        subcategoriesDropDownList.append(dropDownObj)
                        
                    }
                    
                    let category = ProductCategoryForDataRecieving(title: categoryName, subCategories: subcategoriesDropDownList)
                    
                    categoriesData.append(category)
                }
            }
            
            completion(categoriesData) // Return the categories and subcategories
        }
    }
    
    
    func fetchAllAvailableColors(completion: @escaping ([String]) -> Void) {
        // Reference to the colors collection
        let colorsRef = db.collection("Product_colors")
        
        // Fetch all documents in the colors collection
        colorsRef.getDocuments { (snapshot, error) in
            var colorsData: [String] = []  // To store color names
            
            if let error = error {
                print("Error fetching colors: \(error.localizedDescription)")
                completion([]) // Return an empty array on error
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    // Assuming the colors are stored as a list of strings in a field named "colorList"
                    let colorList = document.data()["colors"] as? [String] ?? []
                    colorsData.append(contentsOf: colorList)
                }
            }
            
            completion(colorsData) // Return the array of colors
        }
    }
    
    
    func fetchAllAvailableSizes(completion: @escaping ([String]) -> Void) {
        // Reference to the colors collection
        let colorsRef = db.collection("ProductSizes")
        
        // Fetch all documents in the colors collection
        colorsRef.getDocuments { (snapshot, error) in
            var colorsData: [String] = []  // To store color names
            
            if let error = error {
                print("Error fetching colors: \(error.localizedDescription)")
                completion([]) // Return an empty array on error
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    // Assuming the colors are stored as a list of strings in a field named "colorList"
                    let colorList = document.data()["allSize"] as? [String] ?? []
                    colorsData.append(contentsOf: colorList)
                }
            }
            
            completion(colorsData) // Return the array of colors
        }
    }
    
    func fetchAllAvailableFabrics(completion: @escaping ([String]) -> Void) {
        // Reference to the colors collection
        let colorsRef = db.collection("Product_fabrics")
        
        // Fetch all documents in the colors collection
        colorsRef.getDocuments { (snapshot, error) in
            var colorsData: [String] = []  // To store color names
            
            if let error = error {
                print("Error fetching colors: \(error.localizedDescription)")
                completion([]) // Return an empty array on error
                return
            }
            
            if let snapshot = snapshot {
                for document in snapshot.documents {
                    // Assuming the colors are stored as a list of strings in a field named "colorList"
                    let colorList = document.data()["fabrics"] as? [String] ?? []
                    colorsData.append(contentsOf: colorList)
                }
            }
            
            completion(colorsData) // Return the array of colors
        }
    }
    
}

    



