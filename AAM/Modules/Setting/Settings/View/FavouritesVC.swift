//
//  FavouritesVC.swift
//  AAM
//
//  Created by Arif on 29/01/2025.
//

import UIKit

class FavouritesVC: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Properties
    private let viewModel = FavouritesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        setupBindings()
        fetchFavourites()
    }
    
    // MARK: - Setup
    
    private func setupTableView() {
        tableView.delegate   = self
        tableView.dataSource = self
        
        // Register the cell nib
        let nib = UINib(nibName: FavouritesProductsTblCell.identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: FavouritesProductsTblCell.identifier)
    }
    
    private func setupBindings() {
        // 1) When the products are fetched
        viewModel.onFavouritesFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        // 2) If an error occurs
        viewModel.onError = { [weak self] errorMessage in
            DispatchQueue.main.async {
                print("Error fetching favorites: \(errorMessage)")
                // Optionally, show an alert
                // Helper.showAlert(title: "Error", msg: errorMessage, vc: self)
            }
        }
    }
    
    private func fetchFavourites() {
        // Show a loader if you want
        // LoaderManager.shared.showLoader(on: view, message: "Loading...")
        
        viewModel.fetchFavouriteProducts()
        
        // You can hide loader in the callback if needed
    }
    
    @IBAction func backBtnAction() {
        Router.pop(from: self)
    }
}

// MARK: - UITableViewDelegate & UITableViewDataSource
extension FavouritesVC: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: FavouritesProductsTblCell.identifier,
            for: indexPath
        ) as? FavouritesProductsTblCell else {
            return UITableViewCell()
        }
        
        let product = viewModel.product(at: indexPath.row)
        cell.configure(with: product)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let tappedProduct = viewModel.product(at: indexPath.row)
        
        Router.MoveToProductDetail(from: self, product: tappedProduct)

    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130
    }
}

