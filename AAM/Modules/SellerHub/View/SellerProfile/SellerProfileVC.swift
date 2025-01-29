//
//  SellerProfileVC.swift
//  AAM
//
//  Created by Arif on 26/12/2024.
//

import UIKit

class SellerProfileVC: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var userMailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var allProductsTitleLabel: UILabel!
    
    @IBOutlet weak var mailIconImageView: UIImageView!
    @IBOutlet weak var locationIconImageView: UIImageView!
    
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    // MARK: - Properties
    
    /// The view model that will fetch user info/products
    var viewModel: SellerProfileViewModel!
    
    /// Diffable Data Source
    private var dataSource: UICollectionViewDiffableDataSource<Section, ProductInfo>?
    
    /// Just one section in our collection view
    private enum Section {
        case main
    }
    
    /// Loader indicator
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupCollectionView()
        setupDiffableDataSource()
        setupBindings()
        
        showLoader()
        
        // 1) Fetch the user info (for userId if provided, else current user)
        viewModel.fetchSellerInfo()
        
        // 2) Fetch all products for that user
        viewModel.fetchAllProducts()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // Example custom fonts (Jost):
        usernameLabel.font         = UIFont(name: "Jost-SemiBold", size: 14)
        aboutMeLabel.font          = UIFont(name: "Jost-SemiBold", size: 14)
        userMailLabel.font         = UIFont(name: "Jost-Regular", size: 12)
        locationLabel.font         = UIFont(name: "Jost-Regular", size: 12)
        allProductsTitleLabel.font = UIFont(name: "Jost-SemiBold", size: 14)
        
        // Round profile image
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode        = .scaleAspectFill
        profileImageView.clipsToBounds      = true
        
        // Example icons (SF Symbols)
        mailIconImageView.image     = UIImage(systemName: "envelope.fill")
        locationIconImageView.image = UIImage(systemName: "mappin.and.ellipse")
        
        // Add the loader in the center
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupCollectionView() {
        // Register the custom cell nib
        let nib = UINib(nibName: ProductCollCell.identifier, bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: ProductCollCell.identifier)
        
        // Configure layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        
        let spacing: CGFloat     = 8
        let totalSpacing: CGFloat = spacing * 3
        let itemWidth: CGFloat   = (view.frame.size.width - totalSpacing) / 2.2
        
        layout.itemSize                = CGSize(width: itemWidth, height: 220)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing      = spacing
        
        productsCollectionView.collectionViewLayout = layout
        productsCollectionView.delegate             = self
    }
    
    private func setupDiffableDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ProductInfo>(
            collectionView: productsCollectionView
        ) { [weak self] (collectionView, indexPath, product) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductCollCell.identifier,
                for: indexPath
            ) as? ProductCollCell else {
                return UICollectionViewCell()
            }
            cell.configure(product: product)
            return cell
        }
    }
    
    /// Bind to the view model’s callbacks
    private func setupBindings() {
        viewModel.onSellerInfoFetched = { [weak self] userModel in
            DispatchQueue.main.async {
                self?.updateSellerInfo(userModel)
            }
        }
        
        viewModel.onProductsFetched = { [weak self] in
            DispatchQueue.main.async {
                self?.updateProductsSnapshot()
                self?.hideLoader()
            }
        }
    }
    
    // MARK: - Update UI with user data
    private func updateSellerInfo(_ userModel: UserModel?) {
        guard let user = userModel else { return }
        
        // Update labels
        usernameLabel.text  = user.name
        aboutMeLabel.text   = "About me"
        userMailLabel.text  = user.email
        locationLabel.text  = user.country ?? "N/A"
        
        // If you have a profile image URL
        if let profileImageURL = user.profileImage,
           let url = URL(string: profileImageURL) {
            
            // Simple fetch, or use SDWebImage
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self, let data = data else { return }
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data)
                }
            }.resume()
        } else {
            // placeholder
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
    // MARK: - Update the collection view with the products
    private func updateProductsSnapshot() {
        guard let dataSource = dataSource else { return }
        
        var snapshot = NSDiffableDataSourceSnapshot<Section, ProductInfo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(viewModel.products, toSection: .main)
        
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
    // MARK: - Loader
    private func showLoader() {
        activityIndicator.startAnimating()
    }
    
    private func hideLoader() {
        activityIndicator.stopAnimating()
    }
    
    // MARK: - Action
    @IBAction func backAction() {
        Router.pop(from: self)
    }
}

// MARK: - UICollectionViewDelegate
extension SellerProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If you want to navigate to detail
        let selectedProduct = viewModel.products[indexPath.item]
        Router.MoveToProductDetail(from: self, product: selectedProduct)
    }
}

