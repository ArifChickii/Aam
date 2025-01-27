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
import FirebaseFunctions


class FirebaseService {
    private var db = Firestore.firestore()
     var auth = Auth.auth()
    private let functions = Functions.functions()
    
    
    // MARK: - User Info Saving Method
    /// Saves or updates user information in the Firestore `users` collection.
    func saveUserInformation(user: UserModel, completion: @escaping (Result<Void, Error>) -> Void) {
        let userRef = db.collection("users").document(user.uid)
        
        do {
            let userData = try Firestore.Encoder().encode(user)
            userRef.setData(userData, merge: true) { error in
                if let error = error {
                    print("❌ Error saving user info: \(error.localizedDescription)")
                    completion(.failure(error))
                } else {
                    print("✅ User info saved/updated successfully for UID: \(user.uid)")
                    completion(.success(()))
                }
            }
        } catch let error {
            print("❌ Error encoding user info: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }
    
    
    
    
    func ensureStripeCustomerId(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let uid = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        let userRef = db.collection("users").document(uid)
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            if let document = document, document.exists {
                if let stripeCustomerId = document.data()?["stripeCustomerId"] as? String, !stripeCustomerId.isEmpty {
                    // Stripe customer ID exists
                    completion(.success(()))
                } else {
                    // Create Stripe customer
                    self.createStripeCustomer(completion: completion)
                }
            } else {
                // User document does not exist; create it and then create Stripe customer
                userRef.setData([:]) { error in
                    if let error = error {
                        completion(.failure(error))
                    } else {
                        self.createStripeCustomer(completion: completion)
                    }
                }
            }
        }
    }

    private func createStripeCustomer(completion: @escaping (Result<Void, Error>) -> Void) {
        functions.httpsCallable("createStripeCustomer").call { result, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
    
    
    func fetchProducts(completion: @escaping ([ProductInfo]) -> Void) {
        db.collection("Products").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion([])
            } else {
                var products: [ProductInfo] = []
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    if let productCatDic = data["category"] as? [String: Any] {
                        let productCat = ProductCategory(
                            title: productCatDic["title"] as? String ?? "",
                            subCategories: productCatDic["subCategories"] as? [String] ?? []
                        )
                        
                        let product = ProductInfo(
                            id: document.documentID,
                            sellerId: data["sellerId"] as? String ?? "",
                            images: data["images"] as? [String] ?? [],
                            sizes: data["sizes"] as? [String] ?? [],
                            colors: data["colors"] as? [String] ?? [],
                            fabrics: data["fabrics"] as? [String] ?? [],
                            category: productCat,
                            title: data["title"] as? String ?? "",
                            description: data["description"] as? String ?? "", price: data["price"] as? String ?? "", // old hard-coded
                            rating: data["rating"] as? String ?? "",
                            cutPrice: data["cutPrice"] as? String ?? "0.0",
                            createdAt: data["createdAt"] as? String ?? "",
                            status: data["status"] as? String ?? ""
                        )
                        
                        products.append(product)
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
            
            do {
                // Decode the document into ProductInfo
                let product = try document.data(as: ProductInfo.self)
                completion(product)
            } catch let decodingError {
                print("❌ Error decoding product: \(decodingError.localizedDescription)")
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
    
    
    
    func saveProductInfo(product: ProductInfo,
                         completion: @escaping (Result<String, Error>) -> Void) {
        guard let currentUser = auth.currentUser else {
            completion(.failure(NSError(domain: "FirebaseService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let productsRef = db.collection("Products")
        let newProductRef = productsRef.document()
        
        var productWithID = product
        productWithID.id = newProductRef.documentID
        productWithID.sellerId = currentUser.uid
        productWithID.status = "active" // default status
        
        // Set createdAt
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        productWithID.createdAt = dateFormatter.string(from: Date())
        
        do {
            let productData = try Firestore.Encoder().encode(productWithID)
            
            newProductRef.setData(productData) { [weak self] error in
                guard let self = self else { return }
                
                if let error = error {
                    completion(.failure(error))
                } else {
                    // ========== NEW CODE ========== //
                    // After creating the product with status="active",
                    // increment the user's activeCount by 1.
                    self.incrementSellerStat(for: currentUser.uid,
                                             field: "activeCount",
                                             delta: 1) { incResult in
                        switch incResult {
                        case .success():
                            completion(.success(newProductRef.documentID))
                        case .failure(let statError):
                            completion(.failure(statError))
                        }
                    }
                    // ================================
                }
            }
        } catch {
            completion(.failure(error))
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

    /// Update an existing product in Firestore using the `product.id`
    func updateProductInfo(product: ProductInfo, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let productId = product.id else {
            completion(.failure(NSError(domain: "FirebaseService",
                                        code: -1,
                                        userInfo: [NSLocalizedDescriptionKey: "No product ID found for update"])))
            return
        }
        
        // We store the updated date/time. Or keep the old createdAt if you prefer.
        // For example, let's just keep the old "createdAt".
        
        do {
            // Convert the Product object to a dictionary
            let productData = try Firestore.Encoder().encode(product)
            
            // Overwrite the existing document
            db.collection("Products").document(productId).setData(productData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        } catch let error {
            completion(.failure(error))  // Error during encoding
        }
    }
    
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
    

    func fetchBagProducts(completion: @escaping (Result<[BagProduct], Error>) -> Void) {
        let bagProductsRef = db.collection("BagProducts")
        bagProductsRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error fetching bag products: \(error.localizedDescription)")
                completion(.failure(error))
                return
            }
            
            guard let snapshot = snapshot else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data found."])))
                return
            }
            
            var bagProducts: [BagProduct] = []
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
                        completion(.failure(error))
                        return
                    }
                } else {
                    print("Error parsing bag product data")
                    let parsingError = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Error parsing bag product data"])
                    completion(.failure(parsingError))
                    return
                }
            }
            completion(.success(bagProducts))
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
    
    func fetchSellerStats(for sellerId: String,
                          completion: @escaping (Result<[String: Any], Error>) -> Void) {
        let statsRef = db.collection("sellerStats").document(sellerId)
        statsRef.getDocument { docSnapshot, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let snapshot = docSnapshot, snapshot.exists,
                  let data = snapshot.data() else {
                completion(.success([:])) // Return empty if doc doesn't exist yet
                return
            }
            completion(.success(data))
        }
    }
    
    // Helper: increment a single field in the sellerStats doc
    //         i.e. "activeCount", "soldCount", "unsoldCount"
    // ---------------------------------------------------------------------
    func incrementSellerStat(for sellerId: String,
                             field: String,
                             delta: Int,
                             completion: @escaping (Result<Void, Error>) -> Void) {
        let statsRef = db.collection("sellerStats").document(sellerId)
        statsRef.updateData([
            field: FieldValue.increment(Int64(delta))
        ]) { error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        }
    }
                             
}

extension FirebaseService {
    



    
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
    // 2) Delete a product (in a transaction), decrementing the relevant
    //    seller stat. If status is "active", decrement activeCount; if "sold",
    //    decrement soldCount; else decrement unsoldCount.
    // ---------------------------------------------------------------------
    func deleteProduct(productId: String,
                                     completion: @escaping (Result<Void, Error>) -> Void) {
        
        let productRef = db.collection("Products").document(productId)
        
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            // 1) Read the product doc
            guard let productSnapshot = try? transaction.getDocument(productRef),
                  let data = productSnapshot.data(),
                  let sellerId = data["sellerId"] as? String,
                  let oldStatusRaw = data["status"] as? String else {
                
                errorPointer?.pointee = NSError(domain: "FirebaseService",
                                                code: -1,
                                                userInfo: [NSLocalizedDescriptionKey: "Product doc not found or missing fields"])
                return nil
            }
            
            // Map old status to "active"/"sold"/"unsold"
            let oldStatus = self.mapToRecognizedStatus(oldStatusRaw)
            
            // 2) Decrement the correct stat for old status
            let statsRef = self.db.collection("sellerStats").document(sellerId)
            
            switch oldStatus {
            case "active":
                transaction.updateData(["activeCount": FieldValue.increment(Int64(-1))],
                                       forDocument: statsRef)
            case "sold":
                transaction.updateData(["soldCount": FieldValue.increment(Int64(-1))],
                                       forDocument: statsRef)
            case "unsold":
                transaction.updateData(["unsoldCount": FieldValue.increment(Int64(-1))],
                                       forDocument: statsRef)
            default:
                break
            }
            
            // 3) Delete the product document
            transaction.deleteDocument(productRef)
            
            return nil
        }, completion: { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(()))
            }
        })
    }
    
    // 3) Mark a product as sold — for OrderInfoVC's "Confirm" button, etc.
    //    This just calls setProductStatus(..., newStatus: "sold").
    // ---------------------------------------------------------------------
    func markProductAsSold(productId: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {
        // Re-use the existing setProductStatus approach:
        setProductStatus(productId: productId, newStatus: "sold", completion: completion)
    }
    
    // (Existing) setProductStatus for any arbitrary status
     // e.g. "sold", "active", or anything else => "unsold"
     // ---------------------------------------------------------------------
     func setProductStatus(productId: String,
                           newStatus: String,
                           completion: @escaping (Result<Void, Error>) -> Void) {

         let productRef = db.collection("Products").document(productId)

         db.runTransaction({ (transaction, errorPointer) -> Any? in
             guard let productSnapshot = try? transaction.getDocument(productRef),
                   let oldData = productSnapshot.data(),
                   let oldStatusRaw = oldData["status"] as? String,
                   let sellerId = oldData["sellerId"] as? String else {
                 
                 errorPointer?.pointee = NSError(domain: "AppError",
                                                 code: -1,
                                                 userInfo: [NSLocalizedDescriptionKey: "Product not found or missing fields"])
                 return nil
             }
             
             let mappedOldStatus = self.mapToRecognizedStatus(oldStatusRaw)
             let mappedNewStatus = self.mapToRecognizedStatus(newStatus)

             if mappedOldStatus != mappedNewStatus {
                 let statsRef = self.db.collection("sellerStats").document(sellerId)
                 
                 // Decrement old
                 switch mappedOldStatus {
                 case "active":
                     transaction.updateData(["activeCount": FieldValue.increment(Int64(-1))],
                                            forDocument: statsRef)
                 case "sold":
                     transaction.updateData(["soldCount": FieldValue.increment(Int64(-1))],
                                            forDocument: statsRef)
                 case "unsold":
                     transaction.updateData(["unsoldCount": FieldValue.increment(Int64(-1))],
                                            forDocument: statsRef)
                 default:
                     break
                 }

                 // Increment new
                 switch mappedNewStatus {
                 case "active":
                     transaction.updateData(["activeCount": FieldValue.increment(Int64(1))],
                                            forDocument: statsRef)
                 case "sold":
                     transaction.updateData(["soldCount": FieldValue.increment(Int64(1))],
                                            forDocument: statsRef)
                 case "unsold":
                     transaction.updateData(["unsoldCount": FieldValue.increment(Int64(1))],
                                            forDocument: statsRef)
                 default:
                     break
                 }
             }
             
             // Update product doc's "status" field
             transaction.updateData(["status": newStatus], forDocument: productRef)
             
             return nil
         }, completion: { _, error in
             if let error = error {
                 completion(.failure(error))
             } else {
                 completion(.success(()))
             }
         })
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
    
    
    
    // MARK: - Delete Shipping Address Method

        /// Deletes a shipping address from Firebase.
        /// - Parameters:
        ///   - addressId: The ID of the address to delete.
        ///   - completion: Completion handler with a result.
        func deleteShippingAddress(addressId: String, completion: @escaping (Result<Void, Error>) -> Void) {
            guard let userId = auth.currentUser?.uid else {
                completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
                return
            }
            let addressRef = db.collection("users").document(userId).collection("shippingAddresses").document(addressId)
            addressRef.delete { error in
                if let error = error {
                    completion(.failure(error))  // Return failure if there's an error
                } else {
                    completion(.success(()))  // Success, address deleted
                }
            }
        }
    
    // MARK: - Shipping Address Methods

    /// Saves or updates a shipping address for the current user in Firebase.
    /// - Parameters:
    ///   - address: The `ShippingAddress` object to save or update.
    ///   - completion: Completion handler with a result.
    func saveShippingAddress(address: ShippingAddress, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        let userAddressesRef = db.collection("users").document(userId).collection("shippingAddresses")
        
        let addressRef: DocumentReference
        var mutableAddress = address // Create a mutable copy of the address
        if let addressId = mutableAddress.id {
            // If the address has an ID, we're updating an existing address
            addressRef = userAddressesRef.document(addressId)
        } else {
            // Otherwise, we're adding a new address
            addressRef = userAddressesRef.document()
            mutableAddress.id = addressRef.documentID // Assign the new document ID to the mutable copy
        }
        
        do {
            var addressData = try Firestore.Encoder().encode(mutableAddress)
            // Include the document ID in the data
            addressData["id"] = mutableAddress.id
            
            // Save or update the address data
            addressRef.setData(addressData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    // If the address is set as default, update other addresses
                    if mutableAddress.makeDefaultAddress {
                        self.updateOtherAddressesMakeDefaultFalse(userId: userId, currentAddressId: addressRef.documentID) { result in
                            switch result {
                            case .success():
                                completion(.success(()))
                            case .failure(let error):
                                completion(.failure(error))
                            }
                        }
                    } else {
                        completion(.success(()))
                    }
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }

    
    /// Updates other shipping addresses to set `makeDefaultAddress` to `false`.
    /// - Parameters:
    ///   - userId: The ID of the current user.
    ///   - currentAddressId: The ID of the current address.
    ///   - completion: Completion handler with a result.
    private func updateOtherAddressesMakeDefaultFalse(userId: String, currentAddressId: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let userAddressesRef = db.collection("users").document(userId).collection("shippingAddresses")
        
        userAddressesRef.getDocuments { (snapshot, error) in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let batch = self.db.batch()
            
            snapshot?.documents.forEach { document in
                if document.documentID != currentAddressId {
                    batch.updateData(["makeDefaultAddress": false], forDocument: document.reference)
                }
            }
            
            batch.commit { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}

extension FirebaseService {

    /// Saves the given order to Firestore.
    /// - Parameters:
    ///   - order: The `Order` object containing all order details.
    ///   - completion: Completion handler with a result that returns the generated order ID on success.
    func saveOrder(order: Order, completion: @escaping (Result<String, Error>) -> Void) {
        // Ensure the user is logged in to associate the order with them
        guard let userId = auth.currentUser?.uid else {
            completion(.failure(NSError(domain: "FirebaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])))
            return
        }
        
        // Reference to 'Orders' collection
        let ordersRef = db.collection("Orders")
        
        // Create a new document with an automatically generated ID
        let newOrderRef = ordersRef.document()
        
        var orderWithID = order
        orderWithID.id = newOrderRef.documentID
        orderWithID.userId = userId
        
        do {
            // Encode the order
            let orderData = try Firestore.Encoder().encode(orderWithID)
            
            // Save the order data
            newOrderRef.setData(orderData) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(newOrderRef.documentID))
                }
            }
        } catch let error {
            completion(.failure(error))
        }
    }

}
extension FirebaseService {
    
    /// Fetches user information from the Firestore `users` collection by user ID.
    /// - Parameters:
    ///   - uid: The user's unique ID.
    ///   - completion: A completion handler returning a `Result<UserModel, Error>`.
    func fetchUserInformation(uid: String, completion: @escaping (Result<UserModel, Error>) -> Void) {
        let userRef = db.collection("users").document(uid)
        
        userRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let document = document, document.exists else {
                let err = NSError(domain: "FirebaseService",
                                  code: -1,
                                  userInfo: [NSLocalizedDescriptionKey: "User document does not exist for uid: \(uid)"])
                completion(.failure(err))
                return
            }
            
            do {
                // Decode Firestore document into UserModel
                let userModel = try document.data(as: UserModel.self)
                completion(.success(userModel))
            } catch {
                completion(.failure(error))
            }
        }
    }
}
extension FirebaseService {
    /// Updates the status of a product.
    /// - Parameters:
    ///   - productId: The ID of the product to update.
    ///   - newStatus: The new status (e.g., "sold").
    ///   - completion: Completion handler with a result.
    func updateProductStatus(productId: String, newStatus: String, completion: @escaping (Result<Void, Error>) -> Void) {
        let productRef = db.collection("Products").document(productId)
        productRef.updateData(["status": newStatus]) { error in
            if let error = error {
                print("❌ Failed to update product status: \(error.localizedDescription)")
                completion(.failure(error))
            } else {
                print("✅ Product status updated to \(newStatus) for ID: \(productId)")
                completion(.success(()))
            }
        }
    }
}
extension FirebaseService {

  

    // Utility: map ANY status that is not "active" or "sold" => "unsold"
    // ---------------------------------------------------------------------
    private func mapToRecognizedStatus(_ status: String) -> String {
        if status == "active" {
            return "active"
        } else if status == "sold" {
            return "sold"
        } else {
            return "unsold"
        }
    }
}

extension FirebaseService {
    
    /// Creates or updates the sellerStats/{userId} doc for the current user.
    /// All products that do not have `status == "sold"` are counted as "active".
    func createOrUpdateSellerStatsForCurrentUser(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = auth.currentUser else {
            let err = NSError(domain: "FirebaseService",
                              code: -1,
                              userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            completion(.failure(err))
            return
        }
        
        // Fetch all products
        fetchProducts { [weak self] allProducts in
            guard let self = self else { return }
            
            // Filter products by the current user's ID
            let userProducts = allProducts.filter { $0.sellerId == currentUser.uid }
            
            // Count how many are sold vs. active
            var soldCount = 0
            for product in userProducts {
                if product.status == "sold" {
                    soldCount += 1
                }
            }
            let activeCount = userProducts.count - soldCount
            // If you want an "unsoldCount" you can also store that, or just store activeCount & soldCount.
            
            let statsData: [String: Any] = [
                "activeCount": activeCount,
                "soldCount":   soldCount
            ]
            
            // Write to sellerStats/{userId}
            let statsRef = self.db.collection("sellerStats").document(currentUser.uid)
            statsRef.setData(statsData, merge: true) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
