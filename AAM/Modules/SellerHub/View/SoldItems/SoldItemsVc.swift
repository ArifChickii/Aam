//
//  SoldItemsVc.swift
//  AAM
//
//  Created by Arif on 29/12/2024.
//


import UIKit

class SoldItemsVc: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Properties
    private let viewModel = SoldItemsViewModel()
    
    // Loader indicator (optional but recommended)
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        setupBindings()
        
        showLoader()
        viewModel.fetchSoldProducts()  // Fetch user’s sold products
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Add loader to center
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func setupCollectionView() {
        collectionView.delegate   = self
        collectionView.dataSource = self
        
        // Register the custom cell nib
        let nib = UINib(nibName: ProductCollCell.identifier, bundle: nil)
        collectionView.register(nib, forCellWithReuseIdentifier: ProductCollCell.identifier)
        
        // If needed, configure layout (e.g. flow layout, spacing, etc.)
        // For example:
        // if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
        //     layout.minimumLineSpacing = 10
        //     layout.minimumInteritemSpacing = 10
        // }
    }
    
    private func setupBindings() {
        // The view model notifies us when sold products are fetched
        viewModel.onSoldProductsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.hideLoader()
                self?.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Loader Helpers
    private func showLoader() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoader() {
        activityIndicator.stopAnimating()
    }
    // MARK: - Actions
    @IBAction func backAction(){
        Router.pop(from: self)
    }
}

// MARK: - UICollectionViewDataSource
extension SoldItemsVc: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductCollCell.identifier,
                for: indexPath
              ) as? ProductCollCell else {
            return UICollectionViewCell()
        }
        
        let product = viewModel.product(at: indexPath.row)
        cell.configure(product: product)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension SoldItemsVc: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let tappedProduct = viewModel.product(at: indexPath.row)
        // Handle cell tap if needed (e.g., navigate to details, etc.)
        print("Tapped sold product: \(tappedProduct.title ?? "")")
    }
}

// MARK: - UICollectionViewDelegateFlowLayout (optional for layout)
extension SoldItemsVc: UICollectionViewDelegateFlowLayout {
    
    // Example size configuration
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Example: 2 columns with 10 spacing on each side
        let width = (collectionView.frame.width / 2) - 15
        return CGSize(width: width, height: 220)
    }
}

