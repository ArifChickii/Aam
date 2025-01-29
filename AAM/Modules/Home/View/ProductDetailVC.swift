//
//  ProductDetailVC.swift
//  AAM
//
//  Created by Arif ww on 21/08/2024.
//

import UIKit
import SDWebImage

class ProductDetailVC: UIViewController, Storyboarded {
    // MARK: - Properties
    var viewModel: ProductDetailViewModel?
    var productDetailObj: ProductInfo?

    @IBOutlet weak var productTblView: UITableView!
    
    // Add loading state
    private var isLoading = false {
        didSet {
            productTblView?.isHidden = isLoading
        }
    }
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup methods
        setupDeepLinkObserver()
        setDelegatesAndDataSources()
        registerCells()
        
        // Hide table view initially if no product
        productTblView.isHidden = viewModel == nil
        
        // Initial UI setup if productDetailObj is already set
        if let product = productDetailObj {
            setupView(with: product)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // If productDetailObj is already set (e.g., from previous navigation), set up the view
        if let product = productDetailObj {
            setupView(with: product)
        }
    }
    
    deinit {
        // Remove observer to prevent memory leaks
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name("ProductDeepLink"), object: nil)
    }
    
    // MARK: - Setup Methods
    
    private func setupDeepLinkObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleDeepLink(_:)),
            name: NSNotification.Name("ProductDeepLink"),
            object: nil
        )
    }
    
    private func setDelegatesAndDataSources() {
        productTblView.delegate = self
        productTblView.dataSource = self
    }
    
    private func registerCells() {
        productTblView.register(UINib(nibName: ProductImageTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductImageTblCell.identifier)
        productTblView.register(UINib(nibName: ProductPriceAndTitleTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductPriceAndTitleTblCell.identifier)
        productTblView.register(UINib(nibName: ProductDescriptionTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductDescriptionTblCell.identifier)
        productTblView.register(UINib(nibName: ProductSizeTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductSizeTblCell.identifier)
        productTblView.register(UINib(nibName: ProductAddToBagTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductAddToBagTblCell.identifier)
        productTblView.register(UINib(nibName: ProductCategoryTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductCategoryTblCell.identifier)
        productTblView.register(UINib(nibName: ProductRatingTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductRatingTblCell.identifier)
        
        productTblView.estimatedRowHeight = 80
        productTblView.rowHeight = UITableView.automaticDimension
    }
    
    // MARK: - Product Loading
    
    func loadProduct(withId productId: String) {
        isLoading = true
        
        // Show loading indicator
        let loadingVC = UIAlertController(title: nil, message: "Loading...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingVC.view.addSubview(loadingIndicator)
        present(loadingVC, animated: true)
        
        // Fetch product using FirebaseService
        let productService = FirebaseService()
        productService.fetchProduct(withId: productId) { [weak self] product in
            DispatchQueue.main.async {
                // Dismiss loading indicator
                loadingVC.dismiss(animated: true) {
                    guard let self = self else { return }
                    
                    guard let product = product else {
                        print("❌ Product not found for ID: \(productId)")
                        self.showErrorAlert(message: "Product not found.")
                        self.navigationController?.popViewController(animated: true)
                        return
                    }
                    
                    // Setup view with fetched product
                    self.setupView(with: product)
                    self.isLoading = false
                }
            }
        }
    }
    
    private func setupView(with product: ProductInfo) {
        self.productDetailObj = product
        self.viewModel = ProductDetailViewModel(product: product)
        self.productTblView.isHidden = false
        
        // Check if product is in bag using ViewModel
        self.viewModel?.checkIfProductIsInBag { [weak self] isInBag in
            DispatchQueue.main.async {
                // Reload the table view to update the Add to Bag button
                self?.productTblView.reloadData()
            }
        }
    }
    
    // MARK: - Action Methods
    
    @IBAction func backAction() {
        Router.pop(from: self)
    }
    
    // MARK: - Deep Link Handling
    
    @objc private func handleDeepLink(_ notification: Notification) {
        guard let productId = notification.userInfo?["productId"] as? String else {
            print("❌ Product ID not found in notification")
            return
        }
        
        loadProduct(withId: productId)
    }
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource

extension ProductDetailVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
            
            return viewModel.product.owner_infor == nil ? 6 : 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // Safety check for viewModel
        guard let viewModel = viewModel else {
            return UITableViewCell()
        }
        
        switch indexPath.row {
        case 0:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductImageTblCell.identifier, for: indexPath) as? ProductImageTblCell else {
                return UITableViewCell()
            }
            cell.configure(obj: viewModel.product)
            return cell
            
        case 1:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductPriceAndTitleTblCell.identifier, for: indexPath) as? ProductPriceAndTitleTblCell else {
                return UITableViewCell()
            }
            // Configure share button
            cell.btnShare.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnShare.tag = indexPath.row
            cell.btnShare.addTarget(self, action: #selector(shareBtnTapped(_:)), for: .touchUpInside)
            
            // Configure delete button
            cell.btnDelete.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnDelete.tag = indexPath.row
            cell.btnDelete.addTarget(self, action: #selector(deleteBtnTapped(_:)), for: .touchUpInside)
            
            // NEW: Hide or show the delete button based on whether this user is the seller
            cell.btnDelete.isHidden = !viewModel.isCurrentUserSeller
            
            // Configure cell data
            cell.configure(obj: viewModel.product)
            return cell
            
        case 2:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductDescriptionTblCell.identifier, for: indexPath) as? ProductDescriptionTblCell else {
                return UITableViewCell()
            }
            cell.configure(obj: viewModel.product)
            return cell
            
        case 3:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductSizeTblCell.identifier, for: indexPath) as? ProductSizeTblCell else {
                return UITableViewCell()
            }
            cell.configure(obj: viewModel.product)
            return cell
            
        case 4:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductAddToBagTblCell.identifier, for: indexPath) as? ProductAddToBagTblCell else {
                return UITableViewCell()
            }
            cell.btnAddToBag.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnAddToBag.tag = indexPath.row
            cell.btnAddToBag.addTarget(self, action: #selector(addToBagBtnTapped(_:)), for: .touchUpInside)
            // Update the button based on ViewModel's state
            cell.updateAddToBagButton(isInBag: viewModel.isProductInBag)
            return cell
            
        case 5:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: ProductCategoryTblCell.identifier, for: indexPath) as? ProductCategoryTblCell else {
                return UITableViewCell()
            }
            cell.configure(obj: viewModel.product)
            return cell
            
        case 6:
            // The new "owner info" row, using ProductRatingTblCell
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: ProductRatingTblCell.identifier,
                for: indexPath
            ) as? ProductRatingTblCell else {
                return UITableViewCell()
            }
            cell.configureOwnerInfo(product: viewModel.product)
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    @objc func shareBtnTapped(_ sender: UIButton) {
        guard let product = productDetailObj else {
            print("❌ No product available to share")
            showErrorAlert(message: "No product available to share.")
            return
        }
        ProductShareManager.shared.shareProduct(
            product: product,
            sender: sender,
            from: self
        )
    }
    
    @objc func deleteBtnTapped(_ sender: UIButton) {
        // Show confirmation alert
        let alert = UIAlertController(title: "Delete Product", message: "Are you sure you want to delete this product?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            guard let self = self else { return }
            self.performDeleteProduct()
        }))
        present(alert, animated: true)
    }
    
    func performDeleteProduct() {
        // Show loader
        let loadingVC = UIAlertController(title: nil, message: "Deleting...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingVC.view.addSubview(loadingIndicator)
        present(loadingVC, animated: true)
        
        // Call deleteProduct on viewModel
        viewModel?.deleteProduct { [weak self] result in
            DispatchQueue.main.async {
                loadingVC.dismiss(animated: true) {
                    guard let self = self else { return }
                    switch result {
                    case .success():
                        self.showToast(message: "Product deleted successfully")
                        // Pop or dismiss the view controller
                        self.navigationController?.popViewController(animated: true)
                    case .failure(let error):
                        self.showErrorAlert(message: "Failed to delete product: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    @objc func addToBagBtnTapped(_ sender: UIButton) {
        guard let viewModel = viewModel else { return }
        
        // Show loader
        let loadingVC = UIAlertController(title: nil, message: "Adding to Bag...", preferredStyle: .alert)
        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = .medium
        loadingIndicator.startAnimating()
        loadingVC.view.addSubview(loadingIndicator)
        present(loadingVC, animated: true)
        
        // Add product to bag via ViewModel
        viewModel.addToBag { [weak self] result in
            DispatchQueue.main.async {
                // Dismiss loader
                loadingVC.dismiss(animated: true) {
                    guard let self = self else { return }
                    switch result {
                    case .success:
                        // Show success message and update UI
                        self.showToast(message: "Product added to bag")
                        // Reload the Add to Bag cell to update its state
                        self.productTblView.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .none)
                    case .failure(let error):
                        // Show error message
                        self.showErrorAlert(message: "Failed to add product to bag: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 400
        case 1, 2, 3:
            return UITableView.automaticDimension
        case 4:
            return 50
        case 5:
            return 100
        case 6:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

