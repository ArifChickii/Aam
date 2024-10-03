import Foundation

class ProductsViewModel {
    private let productService: FirebaseService
    var products: [ProductInfo] = []
    private var filteredProducts: [ProductInfo] = []
    var isFiltering: Bool = false
    var onProductsFetched: (() -> Void)?

    init(productService: FirebaseService = FirebaseService()) {
        self.productService = productService
        self.fetchCategories()
        self.fetchAllColors()
        self.fetchAllSizes()
        self.fetchAllFabrics()
    }

    func fetchProducts(completion: (() -> Void)? = nil) {
        productService.fetchProducts { [weak self] products in
            self?.products = products
            self?.filteredProducts = self?.products ?? []
            self?.onProductsFetched?()
            completion?() // Call the completion closure if provided
        }
    }
    
    func fetchCategories(completion: (() -> Void)? = nil) {
        productService.fetchCategories { categories in
            print(categories)
//            save them in constant class
            Constants.shared.categoriesList = categories
            completion?()
        }
        
        
        
    }
    
    func fetchAllColors(completion: (() -> Void)? = nil) {
        productService.fetchAllAvailableColors { colors in
            Constants.shared.colorsList.removeAll()
            for color in colors {
                let dropDownbj = DropDown(title: color, isChecked: false)
                Constants.shared.colorsList.append(dropDownbj)
            }
        }
        
        
    }
    
    
    
    
    func fetchAllSizes(completion: (() -> Void)? = nil) {
        productService.fetchAllAvailableSizes { sizes in
            Constants.shared.sizesList.removeAll()
            for size in sizes {
                let dropDownbj = DropDown(title: size, isChecked: false)
                Constants.shared.sizesList.append(dropDownbj)
            }
        }
        
        
    }
    func fetchAllFabrics(completion: (() -> Void)? = nil) {
        
        productService.fetchAllAvailableFabrics { fabrics in
            Constants.shared.fabricList.removeAll()
            for fabric in fabrics {
                let dropDownbj = DropDown(title: fabric, isChecked: false)
                Constants.shared.fabricList.append(dropDownbj)
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
        return isFiltering ? filteredProducts.count : self.products.count
    }

    func product(at index: Int) -> ProductInfo {
        return isFiltering ? filteredProducts[index] : products[index]
    }
    
    
    func filterProducts(by searchText: String) {
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            filteredProducts = products.filter { ($0.title ?? "").lowercased().contains(searchText.lowercased()) }
        }
    }
    
}


