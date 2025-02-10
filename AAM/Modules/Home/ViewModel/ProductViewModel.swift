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
    
    // MARK: - Remove My Own Products
    /// Filters out any product owned by the user with the given userId.
    func removeMyOwnProducts(withUserId userId: String) {
        products = products.filter { $0.owner_infor?.userId != userId }
        filteredProducts = filteredProducts.filter { $0.owner_infor?.userId != userId }
    }
    
    // MARK: - Category/Color/Size/Fabric Fetching
    func fetchCategories(completion: (() -> Void)? = nil) {
        productService.fetchCategories { categories in
            print(categories)
            // Save them in Constants class
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
    
    // MARK: - Table View Helpers
    func numberOfProducts() -> Int {
        return isFiltering ? filteredProducts.count : products.count
    }

    func product(at index: Int) -> ProductInfo {
        return isFiltering ? filteredProducts[index] : products[index]
    }
    
    // MARK: - Filtering by Title or Category
    func filterProducts(by searchText: String, searchingByCategory: Bool) {
        if searchText.isEmpty {
            filteredProducts = products
        } else {
            let lowercasedSearch = searchText.lowercased()
            
            if searchingByCategory {
                // Filter by **Subcategories** within the product's category
                filteredProducts = products.filter { product in
                    let subCats = product.category?.subCategories ?? []
                    
                    // Convert subcategories to lowercase for matching
                    return subCats.contains { subCat in
                        subCat.lowercased().contains(lowercasedSearch)
                    }
                }
            } else {
                // Filter by Product Title
                filteredProducts = products.filter {
                    ($0.title ?? "").lowercased().contains(lowercasedSearch)
                }
            }
        }
    }
}

