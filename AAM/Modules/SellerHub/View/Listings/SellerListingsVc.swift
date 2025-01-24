//
//  SellerListingsVc.swift
//  AAM
//
//  Created by Arif on 29/12/2024.
//

import UIKit



class SellerListingsVc: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblTitleListingFee: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    @IBOutlet weak var lblAllItems: UILabel!
    // MARK: - Properties
    private let viewModel = SellerListingsViewModel()
    
    // Loader indicator (optional)
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupBindings()
        showLoader()
        viewModel.fetchUserProducts()  // fetch all user’s products
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // If you want a title
        // self.title = "My Listings"
        lblTitleListingFee.font          = UIFont(name: "Jost-SemiBold", size: 14)
        lblAllItems.font          = UIFont(name: "Jost-SemiBold", size: 14)
        lblDesc.font   = UIFont(name: "Jost-Regular", size: 12)
        
        
        // Add loader to center
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate   = self
        tableView.dataSource = self
        
        // Register cell nib
        let nib = UINib(nibName: ListingTblCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: ListingTblCell.identifier)
        
        // Optional: Adjust row height or use Auto Layout
        // tableView.rowHeight = 100  (or)
        // tableView.estimatedRowHeight = 100
        // tableView.rowHeight = UITableView.automaticDimension
    }
    
    private func setupBindings() {
        // When products are fetched, reload table
        viewModel.onProductsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Loader
    private func showLoader() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoader() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Action
    @IBAction func backAction(_ sender: Any) {
        Router.pop(from: self)
    }
}

// MARK: - UITableViewDataSource
extension SellerListingsVc: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ListingTblCell.identifier,
            for: indexPath
        ) as? ListingTblCell else {
            return UITableViewCell()
        }
        
        let product = viewModel.product(at: indexPath.row)
        cell.configure(with: product)
        
        // Handle edit button callback
        
        
        cell.onEditTapped = { [weak self] tappedProduct in
            print("Edit tapped for product: \(tappedProduct.title ?? "")")
            // Example:
            // 1) We simply call the Router to move to AddProduct in edit mode:
            Router.MoveToAddProduct(from: self, forEdit: tappedProduct)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension SellerListingsVc: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let tappedProduct = viewModel.product(at: indexPath.row)
        // Optionally, handle row tap if needed
        print("Tapped product: \(tappedProduct.title ?? "")")
        // e.g. Router.MoveToProductDetail(from: self, product: tappedProduct)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

