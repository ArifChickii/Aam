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


