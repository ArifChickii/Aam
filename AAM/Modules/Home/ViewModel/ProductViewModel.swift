import Foundation

class ProductsViewModel {
    private let productService: FirebaseService
    var products: [Product] = []

    var onProductsFetched: (() -> Void)?

    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
    }

    func fetchProducts(completion: (() -> Void)? = nil) {
        productService.fetchProducts { [weak self] products in
            self?.products = products
            self?.onProductsFetched?()
            completion?() // Call the completion closure if provided
        }
    }
    
    func fetchCategories(completion: (() -> Void)? = nil) {
        productService.fetchCategories { categories in
            print(categories)
//            save them in constant class
            completion?()
        }
        
        
        
    }
    
    func fetchAllColors(completion: (() -> Void)? = nil) {
        productService.fetchAllAvailableColors { colors in
            for color in colors {
                print("Color: \(color)")
            }
        }
        
        
    }
    func fetchAllSizes(completion: (() -> Void)? = nil) {
        productService.fetchAllAvailableSizes { sizes in
            for size in sizes {
                print("Color: \(size)")
            }
        }
        
        
    }
    func fetchAllFabrics(completion: (() -> Void)? = nil) {
        productService.fetchAllAvailableFabrics { fabrics in
            for fab in fabrics {
                print("Color: \(fab)")
            }
        }
        
        
    }
    
    

    
    
//    func deleteProduct(){
//        productService.deleteProduct(withId: productIdToDelete) { result in
//            switch result {
//            case .success:
//                print("Product deleted successfully")
//            case .failure(let error):
//                print("Failed to delete product: \(error.localizedDescription)")
//            }
//        }
//    }
    

    func numberOfProducts() -> Int {
        return products.count
    }

    func product(at index: Int) -> Product {
        return products[index]
    }
}


