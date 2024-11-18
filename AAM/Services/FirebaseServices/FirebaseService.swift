//
//  FirebaseService.swift
//  AAM
//
//  Created by Arif ww on 25/08/2024.
//

import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class FirebaseService {
    private var db = Firestore.firestore()
    private var auth = Auth.auth()

    
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

    
    func fetchProduct(withId productId: String, completion: @escaping (ProductInfo?) -> Void) {
        db.collection("Products").document(productId).getDocument { (document, error) in
            if let error = error {
                print("❌ Error fetching product with ID \(productId): \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let document = document, document.exists else {
                print("❌ Product with ID \(productId) does not exist.")
                completion(nil)
                return
            }
            
            let data = document.data()
            
            // Parse the category dictionary safely
            if let productCatDic = data?["category"] as? [String: Any] {
                let productCat = ProductCategory(
                    title: productCatDic["title"] as? String ?? "",
                    subCategories: productCatDic["subCategories"] as? [String] ?? []
                )
                
                let product = ProductInfo(
                    id: document.documentID,
                    images: data?["images"] as? [String] ?? [],
                    sizes: data?["sizes"] as? [String] ?? [],
                    colors: data?["colors"] as? [String] ?? [],
                    fabrics: data?["fabrics"] as? [String] ?? [],
                    category: productCat,
                    title: data?["title"] as? String ?? "",
                    description: data?["description"] as? String ?? "",
                    price: data?["price"] as? String ?? "",
                    rating: data?["rating"] as? String ?? "0.0",
                    cutPrice: data?["cutPrice"] as? String ?? ""
                )
                
                completion(product)
            } else {
                print("❌ Error parsing category for product ID: \(productId)")
                completion(nil)
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

    


extension FirebaseService {


    // MARK: - Bag Products Methods

    /// Adds a product to the bag in Firebase.
    /// - Parameters:
    ///   - product: The product to add.
    ///   - completion: Completion handler with a result.
    func addProductToBag(product: ProductInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        // Reference to the 'BagProducts' collection
        let bagProductsRef = db.collection("BagProducts")
        // Use the product ID as the document ID
        let productRef = bagProductsRef.document(product.id ?? UUID().uuidString)
        
        // Fetch if the product already exists in the bag
        productRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // If exists, increase the count
                if let data = document.data(), let currentCount = data["count"] as? Int {
                    productRef.updateData(["count": currentCount + 1]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } else {
                    // If count is not available, set count to 1
                    productRef.updateData(["count": 1]) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                }
            } else {
                // If not exists, add new document with count 1
                do {
                    // Encode the product
                    let productData = try Firestore.Encoder().encode(product)
                    
                    // Create a dictionary that matches the structure of BagProduct
                    var bagProductData: [String: Any] = [:]
                    bagProductData["id"] = product.id
                    bagProductData["product"] = productData  // Nest the product data under 'product' key
                    bagProductData["count"] = 1  // Add count field
                    
                    // Save the bag product data
                    productRef.setData(bagProductData) { error in
                        if let error = error {
                            completion(.failure(error))
                        } else {
                            completion(.success(()))
                        }
                    }
                } catch let error {
                    completion(.failure(error))
                }
            }
        }
    }
    
    /// Fetches all products in the bag from Firebase.
    /// - Parameter completion: Completion handler with an array of `BagProduct`.
    func fetchBagProducts(completion: @escaping ([BagProduct]) -> Void) {
            let bagProductsRef = db.collection("BagProducts")
            bagProductsRef.getDocuments { (snapshot, error) in
                var bagProducts: [BagProduct] = []
                if let error = error {
                    print("Error fetching bag products: \(error.localizedDescription)")
                    completion([])
                    return
                }
                
                if let snapshot = snapshot {
                    for document in snapshot.documents {
                        let data = document.data()
                        // Manually parse data into BagProduct
                        if let id = data["id"] as? String,
                           let count = data["count"] as? Int,
                           let productData = data["product"] as? [String: Any] {
                            do {
                                // Decode the nested product data
                                let product = try Firestore.Decoder().decode(ProductInfo.self, from: productData)
                                var bagProduct = BagProduct(product: product, count: count)
                                bagProduct.id = id
                                bagProducts.append(bagProduct)
                            } catch let error {
                                print("Error decoding product: \(error.localizedDescription)")
                            }
                        } else {
                            print("Error parsing bag product data")
                        }
                    }
                }
                completion(bagProducts)
            }
        }
    
    /// Updates the count of a product in the bag.
    /// - Parameters:
    ///   - productId: The ID of the product to update.
    ///   - newCount: The new count value.
    ///   - completion: Completion handler with a result.
    func updateBagProductCount(productId: String, newCount: Int, completion: @escaping (Result<Void, Error>) -> Void) {
            let productRef = db.collection("BagProducts").document(productId)
            productRef.updateData(["count": newCount]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // If count reaches zero, delete the product from bag
                    if newCount <= 0 {
                        self.deleteBagProduct(withId: productId) { result in
                            completion(result)
                        }
                    } else {
                        completion(.success(()))
                    }
                }
            }
        }
    
    /// Deletes a product from the bag in Firebase.
    /// - Parameters:
    ///   - productId: The ID of the product to delete.
    ///   - completion: Completion handler with a result.
    func deleteBagProduct(withId productId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            let productRef = db.collection("BagProducts").document(productId)
            productRef.delete { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
}

extension FirebaseService {
    
    // MARK: - Shipping Address Methods
    
    /// Saves a shipping address for the current user to Firebase.
        /// - Parameters:
        ///   - address: The `ShippingAddress` object to save.
        ///   - completion: Completion handler with a result.
    func saveShippingAddress(address: ShippingAddress, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let userAddressesRef = db.collection("users").document(userId).collection("shippingAddresses")
        
        // Use auto-generated ID unless it's the default address
        let addressRef: DocumentReference
        if address.makeDefaultAddress {
            addressRef = userAddressesRef.document("default")
        } else {
            addressRef = userAddressesRef.document() // Auto-generated ID
        }
        
        // Update the address ID within the address object
        var addressWithID = address
        addressWithID.id = addressRef.documentID
        
        do {
            var addressData = try Firestore.Encoder().encode(addressWithID)
            // Include the document ID in the data
            addressData["id"] = addressRef.documentID
            
            // Save the address data
            addressRef.setData(addressData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }


    
     /// Fetches all shipping addresses for the current user from Firebase.
    /// - Parameter completion: Completion handler with a result.
    func fetchShippingAddresses(completion: @escaping (Result<[ShippingAddress], Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }

        let userAddressesRef = db.collection("users").document(userId).collection("shippingAddresses")

        userAddressesRef.getDocuments { snapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            var addresses: [ShippingAddress] = []
            if let documents = snapshot?.documents {
                for document in documents {
                    do {
                        var address = try document.data(as: ShippingAddress.self)
                        address.id = document.documentID
                        addresses.append(address)
                    } catch {
                        print("Error decoding address: \(error)")
                        // Handle decoding error if necessary
                    }
                }
                completion(.success(addresses))
            } else {
                completion(.success([]))
            }
        }
    }
    
    
    
    func checkProductInBag(productId: String, completion: @escaping (Bool) -> Void) {
        let productRef = db.collection("BagProducts").document(productId)
        productRef.getDocument { (document, error) in
            if let document = document, document.exists {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

}
extension FirebaseService {

    // MARK: - Update Shipping Address Method

    /// Updates an existing shipping address in Firebase.
    /// - Parameters:
    ///   - address: The `ShippingAddress` object to update.
    ///   - completion: Completion handler with a result.
    func updateShippingAddress(address: ShippingAddress, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        guard let addressId = address.id else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Address ID not found"])))
            return
        }

        let addressRef = db.collection("users").document(userId).collection("shippingAddresses").document(addressId)

        do {
            let addressData = try Firestore.Encoder().encode(address)
            addressRef.setData(addressData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }
}
