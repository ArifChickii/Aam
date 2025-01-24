//
//  SellerProfileVC.swift
//  AAM
//
//  Created by Arif on 26/12/2024.
//

import UIKit



class SellerProfileVC: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    
    // Profile Image
    @IBOutlet weak var profileImageView: UIImageView!
    
    // Labels
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var aboutMeLabel: UILabel!
    @IBOutlet weak var userMailLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var allProductsTitleLabel: UILabel!
    
    // Icons (mail, location)
    @IBOutlet weak var mailIconImageView: UIImageView!
    @IBOutlet weak var locationIconImageView: UIImageView!
    
    // Collection View
    @IBOutlet weak var productsCollectionView: UICollectionView!
    
    // MARK: - Properties
    private let viewModel = SellerProfileViewModel()
    
    // Diffable Data Source
    private var dataSource: UICollectionViewDiffableDataSource<Section, ProductInfo>?
    
    // Loader indicator
    private var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Enum for diffable sections
    private enum Section {
        case main
    }

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupCollectionView()
        setupDiffableDataSource()
        setupBindings()
        
        // Show loader while data fetches
        showLoader()
        
        // Fetch data
        viewModel.fetchSellerInfo()
        viewModel.fetchAllProducts()
    }
    
    // MARK: - Setup UI
    private func setupUI() {
        // Set Jost fonts
        usernameLabel.font         = UIFont(name: "Jost-SemiBold", size: 14)
        aboutMeLabel.font          = UIFont(name: "Jost-SemiBold", size: 14)
        userMailLabel.font         = UIFont(name: "Jost-Regular", size: 12)
        locationLabel.font         = UIFont(name: "Jost-Regular", size: 12)
        allProductsTitleLabel.font = UIFont(name: "Jost-SemiBold", size: 14)
        
        // Optional: If you want circular profile images
        profileImageView.layer.cornerRadius = profileImageView.frame.width / 2
        profileImageView.contentMode = .scaleAspectFill
        profileImageView.clipsToBounds = true
        
        // Icons (SFSymbols)
        mailIconImageView.image     = UIImage(systemName: "envelope.fill")
        locationIconImageView.image = UIImage(systemName: "mappin.and.ellipse")
        
        // Add loader to the center
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])
    }
    
    private func setupCollectionView() {
        // Register nib for product cell
        let nib = UINib(nibName: ProductCollCell.identifier, bundle: nil)
        productsCollectionView.register(nib, forCellWithReuseIdentifier: ProductCollCell.identifier)
        
        // Setup Layout (2 columns)
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let spacing: CGFloat = 8
        let totalSpacing = (spacing * 3) // left + middle + right
        let itemWidth = (view.frame.size.width - totalSpacing) / 2.2
        layout.itemSize = CGSize(width: itemWidth, height: 220)
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        productsCollectionView.collectionViewLayout = layout
        
        productsCollectionView.delegate = self
    }
    
    private func setupDiffableDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, ProductInfo>(collectionView: productsCollectionView) {
            (collectionView, indexPath, product) -> UICollectionViewCell? in
            
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
    
    /// Sets up the closures / callbacks from the ViewModel
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
    
    // MARK: - Update UI
    private func updateSellerInfo(_ userModel: UserModel?) {
        guard let user = userModel else { return }
        
        // Update labels
        usernameLabel.text  = user.name
        aboutMeLabel.text   = "About me"
        userMailLabel.text  = user.email
        locationLabel.text  = user.country ?? ""
        
        // If you have a profile image URL in userModel
        if let profileImageURL = user.profileImage, let url = URL(string: profileImageURL) {
            // Basic fetch (ideally use a library like SDWebImage)
            URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
                guard let self = self, let data = data else { return }
                DispatchQueue.main.async {
                    self.profileImageView.image = UIImage(data: data)
                }
            }.resume()
        } else {
            // Placeholder
            profileImageView.image = UIImage(systemName: "person.circle.fill")
        }
    }
    
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
    
    // MARK: - Actions
    @IBAction func backAction(){
        Router.pop(from: self)
    }
}

// MARK: - UICollectionViewDelegate
extension SellerProfileVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // If you want to handle tapping on a product
        let selectedProduct = viewModel.products[indexPath.item]
        // e.g., Move to product detail
        Router.MoveToProductDetail(from: self, product: selectedProduct)
    }
}

