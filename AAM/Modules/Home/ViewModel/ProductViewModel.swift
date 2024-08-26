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

    func numberOfProducts() -> Int {
        return products.count
    }

    func product(at index: Int) -> Product {
        return products[index]
    }
}

