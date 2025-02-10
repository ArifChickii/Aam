import UIKit

class HomeVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var productTblView: UITableView!
    @IBOutlet weak var lblSearchBy: UILabel!
    private let viewModel = HomeViewModel()
    private let productViewModel = ProductsViewModel()
    @IBOutlet weak var searchTextField: UITextField!
    
    // A reference to your FirebaseService
    private let firebaseService = FirebaseService()
    
    // Store the IDs of favorite products locally for quick checks
    private var favoriteProductIDs = Set<String>()
    
    // Toggles whether we are searching by Category Title (true) or Product Title (false)
    private var searchingByCategory: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndDataSources()
        registerCells()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 1) Fetch all products from Firestore
        productViewModel.fetchProducts { [weak self] in
            guard let self = self else { return }
            
            // 2) Figure out who the current user is
            if let userId = self.firebaseService.auth.currentUser?.uid {
                // 3) Remove my own products
                self.productViewModel.removeMyOwnProducts(withUserId: userId)
            } else {
                // If there's no logged-in user, do nothing special
                print("No user currently logged in. Showing all products.")
            }
            
            // 4) Reload table to see only other user’s products
            DispatchQueue.main.async {
                self.productTblView.reloadData()
            }
            
            // 5) Now fetch favorite IDs for the current user
            self.fetchFavoriteIDs()
        }
    }
    
    /// Fetch the user's current favorite product IDs from Firestore
    private func fetchFavoriteIDs() {
        // LoaderManager.shared.showLoader(on: self.view, message: "Loading favorites...")
        
        firebaseService.fetchFavoriteProductIDs { [weak self] result in
            guard let self = self else { return }
            LoaderManager.shared.hideLoader()
            
            switch result {
            case .success(let favIDs):
                self.favoriteProductIDs = Set(favIDs)
                // Reload table so we can show correct like icons
                self.productTblView.reloadData()
            case .failure(let error):
                print("Failed to fetch favorite IDs: \(error.localizedDescription)")
            }
        }
    }
    
    private func setDelegatesAndDataSources(){
        searchTextField.delegate  = self
        productTblView.delegate   = self
        productTblView.dataSource = self
    }
    
    private func registerCells() {
        productTblView.register(
            UINib(nibName: ProductTblCell.identifier, bundle: nil),
            forCellReuseIdentifier: ProductTblCell.identifier
        )
    }

    @IBAction func backAction(){
        Router.pop(from: self)
    }
    
    // MARK: - Toggle Search Mode
    @IBAction func toggleSearchMode(_ sender: UIButton) {
        searchingByCategory.toggle()
        
        // Optionally update the button title or UI to indicate the current mode
        let currentMode = searchingByCategory ? "Category" : "Title"
        
        lblSearchBy.text = "Search by: \(currentMode)"
        // Clear existing text and reload data so we start fresh
        searchTextField.text = ""
        productViewModel.isFiltering = false
        productViewModel.filterProducts(by: "",
                                        searchingByCategory: searchingByCategory)
        productTblView.reloadData()
    }
    
    @IBAction func bellIconTapped(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Notification", bundle: nil)
        if let vc = storyboard.instantiateViewController(withIdentifier: "NotificationListVc") as? NotificationListVc {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

}

// MARK: - UITableView
extension HomeVC: UITableViewDelegate, UITableViewDataSource,
                  CollectionViewCellDidSelectDelegate,
                  ProductTblCellDelegate
{
    // ========== 1) For the image collection tapping ==========
    func collectionViewCellDidSelectItem(at indexPath: IndexPath, in tableViewCell: UITableViewCell) {
        if let tableViewIndexPath = productTblView.indexPath(for: tableViewCell) {
            let product = productViewModel.product(at: tableViewIndexPath.row)
            Router.MoveToProductDetail(from: self, product: product)
        }
    }
    
    // ========== 2) For the like button tapping ==========
    
    func didTapLikeButton(in cell: ProductTblCell) {
        guard let indexPath = productTblView.indexPath(for: cell) else { return }
        let tappedProduct = productViewModel.product(at: indexPath.row)
        
        let productId = tappedProduct.id ?? ""
        
        // Check if it's already in favorites
        let isCurrentlyFavorite = favoriteProductIDs.contains(productId)
        
        // We’ll use these after success
        guard let sellerId = tappedProduct.sellerId, !sellerId.isEmpty else {
            print("Product has no seller ID, cannot notify.")
            return
        }
        let productTitle = tappedProduct.title ?? ""
        
        if isCurrentlyFavorite {
            // ========== 1) Remove from favorites ==========
            firebaseService.removeProductFromFavorites(productId: productId) { [weak self] result in
                guard let self = self else { return }
                // LoaderManager.shared.hideLoader() if used
                switch result {
                case .success():
                    // Update local set
                    self.favoriteProductIDs.remove(productId)
                    // Update cell icon
                    cell.setLikeIcon(isFavorite: false)
                    print("Removed product \(tappedProduct.title ?? "") from favorites.")
                    
                    // ========== 2) Notify the seller about "unliked" ==========
                    self.firebaseService.notifySellerAboutLikeChange(
                        sellerId: sellerId,
                        productTitle: productTitle,
                        action: "unliked"
                    ) { notifyResult in
                        switch notifyResult {
                        case .success():
                            print("Push & Notification doc for 'unlike' done.")
                        case .failure(let e):
                            print("Error sending push for 'unlike': \(e.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to remove from favorites: \(error.localizedDescription)")
                }
            }
        } else {
            // ========== 1) Add to favorites ==========
            firebaseService.addProductToFavorites(product: tappedProduct) { [weak self] result in
                guard let self = self else { return }
                // LoaderManager.shared.hideLoader() if used
                switch result {
                case .success():
                    // Update local set
                    self.favoriteProductIDs.insert(productId)
                    // Update cell icon
                    cell.setLikeIcon(isFavorite: true)
                    print("Added product \(tappedProduct.title ?? "") to favorites.")
                    
                    // ========== 2) Notify the seller about "liked" ==========
                    self.firebaseService.notifySellerAboutLikeChange(
                        sellerId: sellerId,
                        productTitle: productTitle,
                        action: "liked"
                    ) { notifyResult in
                        switch notifyResult {
                        case .success():
                            print("Push & Notification doc for 'like' done.")
                        case .failure(let e):
                            print("Error sending push for 'like': \(e.localizedDescription)")
                        }
                    }
                    
                case .failure(let error):
                    print("Failed to add to favorites: \(error.localizedDescription)")
                }
            }
        }
    }

    
    // ========== 3) TableView DataSource ==========
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        productViewModel.numberOfProducts()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: ProductTblCell.identifier,
            for: indexPath
        ) as! ProductTblCell
        
        // Set the delegates
        cell.delegate            = self
        cell.productCellDelegate = self
        
        // Grab product
        let product = productViewModel.product(at: indexPath.row)
        let productId = product.id ?? ""
        
        // Check if it's in favorites
        let isFav = favoriteProductIDs.contains(productId)
        
        // Configure cell with product + isFavorite
        cell.configure(obj: product, isFavorite: isFav)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 400
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let product = productViewModel.product(at: indexPath.row)
        Router.MoveToProductDetail(from: self, product: product)
    }
}

// MARK: - UITextFieldDelegate
extension HomeVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange,
                   replacementString string: String) -> Bool {
        
        let currentText = (textField.text ?? "") as NSString
        let searchText  = currentText.replacingCharacters(in: range, with: string)
        
        productViewModel.isFiltering = !searchText.isEmpty
        
        // Pass the toggled parameter `searchingByCategory` to the filter function
        productViewModel.filterProducts(by: searchText,
                                        searchingByCategory: searchingByCategory)
        
        productTblView.reloadData()
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        productViewModel.isFiltering = false
        productViewModel.filterProducts(by: "",
                                        searchingByCategory: searchingByCategory)
        productTblView.reloadData()
        return true
    }
}

