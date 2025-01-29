//
//  AddProductVC.swift
//  AAM
//
//  Created by Mac on 04/09/2024.
//

import UIKit
import FittedSheets
import IQKeyboardManagerSwift
import FirebaseAuth
import FirebaseFirestore

class AddProductVC: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    @IBOutlet weak var tblAddProduct: UITableView!
    
    // MARK: - Properties
    var viewModel = AddProductViewModel()
    
    /// If this is non-nil, we are editing an existing product
    var editingProduct: ProductInfo? = nil
    
    private let merchantService = MerchantService()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndDataSources()
        registerCells()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleBottomSheetDismissedForCategory(_:)),
            name: .didDismissBottomSheet,
            object: nil
        )
        
        tblAddProduct.translatesAutoresizingMaskIntoConstraints = false
        
        // If we have a product to edit, load it now:
        if let productToEdit = editingProduct {
            viewModel.setupEditMode(with: productToEdit) { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tblAddProduct.reloadData()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didDismissBottomSheet, object: nil)
    }
    
    // MARK: - Notifications
    @objc func handleBottomSheetDismissedForCategory(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let category = userInfo["category"] as? ProductCategoryForDataRecieving,
           let subcategory = userInfo["subcategory"] as? DropDown {
            print("Received data: \(category) and subcategory \(subcategory)")
            
            let prodCategory = ProductCategory(
                title: category.title ?? "",
                subCategories: [subcategory.title ?? ""]
            )
            self.viewModel.selectedCategory = prodCategory
            
            self.tblAddProduct.reloadRows(
                at: [IndexPath(row: 3, section: 0)],
                with: .automatic
            )
        }
    }
    
    // MARK: - Setup
    private func setDelegatesAndDataSources() {
        tblAddProduct.delegate   = self
        tblAddProduct.dataSource = self
    }
    
    private func registerCells() {
        tblAddProduct.register(UINib(nibName: AddPhotoTblCelll.identifier, bundle: nil),
                               forCellReuseIdentifier: AddPhotoTblCelll.identifier)
        tblAddProduct.register(UINib(nibName: AddListingTitleTblCell.identifier, bundle: nil),
                               forCellReuseIdentifier: AddListingTitleTblCell.identifier)
        tblAddProduct.register(UINib(nibName: ProductNameAndDescTblCell.identifier, bundle: nil),
                               forCellReuseIdentifier: ProductNameAndDescTblCell.identifier)
        tblAddProduct.register(UINib(nibName: ExpandableTblCell.identifier, bundle: nil),
                               forCellReuseIdentifier: ExpandableTblCell.identifier)
        tblAddProduct.register(UINib(nibName: RenewalOptionsTblCell.identifier, bundle: nil),
                               forCellReuseIdentifier: RenewalOptionsTblCell.identifier)
        tblAddProduct.register(UINib(nibName: SaveToDraftTblCell.identifier, bundle: nil),
                               forCellReuseIdentifier: SaveToDraftTblCell.identifier)
        tblAddProduct.register(UINib(nibName: UploadButtonTblCell.identifier, bundle: nil),
                               forCellReuseIdentifier: UploadButtonTblCell.identifier)
        
        tblAddProduct.estimatedRowHeight = 80
        tblAddProduct.rowHeight          = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
    
    // MARK: - Actions
    @IBAction func crossAction() {
        Router.dismiss(from: self)
    }
    
    // MARK: - Validate
    func validateAllFields() -> Bool {
        var isValid = true
        
        let indexPathOfImage       = IndexPath(row: 0, section: 0)
        let indexPathOfTitleAndDesc = IndexPath(row: 2, section: 0)
        let indexPathOfCategory    = IndexPath(row: 3, section: 0)
        let indexPathOfSize        = IndexPath(row: 4, section: 0)
        let indexPathOfFabric      = IndexPath(row: 5, section: 0)
        let indexPathOfColor       = IndexPath(row: 6, section: 0)
        let indexPathOfPrice       = IndexPath(row: 7, section: 0)
        
        // Title
        if viewModel.selectedTitle.isEmpty {
            viewModel.isTitleFieldFilled = false
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfTitleAndDesc], with: .automatic)
        }
        
        // Images are required if creating a new product
        if editingProduct == nil {
            if viewModel.imageLists.isEmpty {
                viewModel.showRedBorderOnAddImage = true
                isValid = false
                tblAddProduct.reloadRows(at: [indexPathOfImage], with: .automatic)
            }
        }
        
        // Description
        if viewModel.selectedDesc.isEmpty {
            viewModel.isDescFieldFilled = false
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfTitleAndDesc], with: .automatic)
        }
        
        // Category
        if viewModel.selectedCategory == nil {
            viewModel.showRedBorderOnCategory = true
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfCategory], with: .automatic)
        }
        
        // Size
        if viewModel.selectedSize.isEmpty {
            viewModel.showRedBorderOnSize = true
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfSize], with: .automatic)
        }
        
        // Fabric
        if viewModel.selectedFabric.isEmpty {
            viewModel.showRedBorderOnFabric = true
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfFabric], with: .automatic)
        }
        
        // Color
        if viewModel.selectedColor.isEmpty {
            viewModel.showRedBorderOnColor = true
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfColor], with: .automatic)
        }
        
        // Price
        if viewModel.selectedPriceValues == nil {
            viewModel.showRedBorderOnPrice = true
            isValid = false
            tblAddProduct.reloadRows(at: [indexPathOfPrice], with: .automatic)
        }
        
        return isValid
    }
    
    // MARK: - Upload/Create Button
    @objc func uploadButtonTapped(_ sender: UIButton) {
        view.endEditing(true)
        
        // 1) Validate
        if !validateAllFields() {
            Helper.showAlertWithOnlyOk(title: "Alert",
                                       msg: "Please fill out all fields",
                                       vc: self)
            return
        }
        
        // 2) Check if user is merchant
        LoaderManager.shared.showLoader(on: view, message: "Checking merchant status...")
        
        guard let currentUser = Auth.auth().currentUser else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error",
                             msg: "User not logged in.",
                             vc: self)
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            LoaderManager.shared.hideLoader()
            
            if let error = error {
                Helper.showAlert(title: "Error",
                                 msg: "Failed to fetch user doc: \(error.localizedDescription)",
                                 vc: self)
                return
            }
            
            let data = snapshot?.data() ?? [:]
            if let merchantId = data["stripeMerchantId"] as? String, !merchantId.isEmpty {
                // Already a merchant, proceed
                if self.editingProduct == nil {
                    self.uploadProductFlow()
                } else {
                    self.updateProductFlow()
                }
            } else {
                // We need to create a merchant account first
                self.onboardUserAsMerchantAndThenProceed(withCurrentUser: currentUser)
            }
        }
    }
    
    private func onboardUserAsMerchantAndThenProceed(withCurrentUser currentUser: User) {
        LoaderManager.shared.showLoader(on: view, message: "Creating merchant account...")
        
        guard let email = currentUser.email else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error",
                             msg: "No email found for current user.",
                             vc: self)
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        
        merchantService.addMerchant(email: email,
                                    country: "US",
                                    businessType: "individual",
                                    companyName: "MyStore") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let newMerchantId):
                // Store merchant ID in Firestore
                userRef.updateData(["stripeMerchantId": newMerchantId]) { err in
                    LoaderManager.shared.hideLoader()
                    if let err = err {
                        Helper.showAlert(title: "Error",
                                         msg: "Failed to update Firestore with merchant ID: \(err.localizedDescription)",
                                         vc: self)
                    } else {
                        // Now proceed with create or edit logic
                        if self.editingProduct == nil {
                            self.uploadProductFlow()
                        } else {
                            self.updateProductFlow()
                        }
                    }
                }
            case .failure(let error):
                LoaderManager.shared.hideLoader()
                Helper.showAlert(title: "Error",
                                 msg: "Failed to create merchant: \(error.localizedDescription)",
                                 vc: self)
            }
        }
    }
    
    // MARK: - CREATE (New Product)
    private func uploadProductFlow() {
        LoaderManager.shared.showLoader(on: view,
                                        message: "Uploading Product, please wait...")
        
        // 1) Upload images
        viewModel.uploadImagesToFirebase(images: viewModel.imageLists) { [weak self] imgUrls in
            guard let self = self else { return }
            
            print("Uploaded images: \(imgUrls)")
            
            // 2) Before creating the product, fetch user info to fill owner_infor
            self.fetchUserDetailsAndCreateProduct(imageURLs: imgUrls)
        }
    }
    
    // ========== NEW: Fetch user doc, fill owner_infor, then create product ==========
    private func fetchUserDetailsAndCreateProduct(imageURLs: [String]) {
        
        guard let currentUser = Auth.auth().currentUser else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error", msg: "User not logged in.", vc: self)
            return
        }
        
        let userDocRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userDocRef.getDocument { [weak self] docSnapshot, error in
            guard let self = self else { return }
            
            if let error = error {
                LoaderManager.shared.hideLoader()
                Helper.showAlert(title: "Error", msg: "Failed to fetch user doc: \(error.localizedDescription)", vc: self)
                return
            }
            
            // fallback info
            var userName = "Unknown"
            var profileUrl = ""
            
            if let data = docSnapshot?.data() {
                if let name = data["name"] as? String, !name.isEmpty {
                    userName = name
                }
                if let image = data["profileImage"] as? String, !image.isEmpty {
                    profileUrl = image
                }
            }
            
            // 3) Build ProductInfo with images
            guard var newProduct = self.viewModel.createProductInfo(with: imageURLs) else {
                LoaderManager.shared.hideLoader()
                Helper.showAlert(title: "Error", msg: "Failed to create product object.", vc: self)
                return
            }
            
            // 4) Fill the owner_infor
            let owner = OwnerInfo(userId: currentUser.uid,
                                  userName: userName,
                                  profileImageUrl: profileUrl)
            newProduct.owner_infor = owner
            
            // 5) Save product in Firestore
            self.viewModel.addProductToFirebase(productObj: newProduct) { result in
                LoaderManager.shared.hideLoader()
                
                switch result {
                case .success(_):
                    Helper.shared.showToast(message: "Product uploaded successfully!", vc: self)
                    Router.dismiss(from: self)
                case .failure(let error):
                    Helper.showAlert(title: "Error", msg: error.localizedDescription, vc: self)
                }
            }
        }
    }
    
    // MARK: - UPDATE (Edit Existing)
    private func updateProductFlow() {
        LoaderManager.shared.showLoader(on: view,
                                        message: "Updating Product, please wait...")
        
        guard let editingProduct = editingProduct else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error",
                             msg: "No product to edit.",
                             vc: self)
            return
        }
        
        if viewModel.imageLists.isEmpty {
            doUpdateProductFlow(withImageURLs: editingProduct.images ?? [])
        } else {
            viewModel.uploadImagesToFirebase(images: viewModel.imageLists) { [weak self] imgUrls in
                guard let self = self else { return }
                self.doUpdateProductFlow(withImageURLs: imgUrls)
            }
        }
    }
    
    private func doUpdateProductFlow(withImageURLs imageURLs: [String]) {
        guard var editingProduct = editingProduct else { return }
        
        // Overwrite fields
        editingProduct.title       = viewModel.selectedTitle
        editingProduct.description = viewModel.selectedDesc
        editingProduct.images      = imageURLs
        editingProduct.sizes       = viewModel.selectedSize
        editingProduct.colors      = viewModel.selectedColor
        editingProduct.fabrics     = viewModel.selectedFabric
        editingProduct.category    = viewModel.selectedCategory
        editingProduct.price       = viewModel.selectedPriceValues?.price
        editingProduct.cutPrice    = viewModel.selectedPriceValues?.cutPrice
        
        // Optionally re-fetch user doc if you want to update the owner's profile info?
        // Typically, you'd keep the old `owner_infor`. We'll just keep it as is.
        
        viewModel.updateProductInFirebase(productObj: editingProduct) { [weak self] resultMessage in
            guard let self = self else { return }
            LoaderManager.shared.hideLoader()
            
            if resultMessage.contains("Failed") {
                Helper.showAlert(title: "Error", msg: resultMessage, vc: self)
            } else {
                Helper.shared.showToast(message: "Product updated successfully!", vc: self)
                Router.dismiss(from: self)
            }
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension AddProductVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AddPhotoTblCelll.identifier,
                for: indexPath
            ) as! AddPhotoTblCelll
            
            cell.configure(images: viewModel.imageLists)
            cell.showBorder = viewModel.showRedBorderOnAddImage
            cell.onAddImageTapped = { [weak self] in
                guard let self = self else { return }
                self.viewModel.showRedBorderOnAddImage = false
                
                if self.viewModel.imageLists.count < 7 {
                    self.openImagePicker(for: indexPath.row)
                } else {
                    Helper.showAlert(title: "Alert",
                                     msg: StringConstants.maxImagesReached,
                                     vc: self)
                }
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: AddListingTitleTblCell.identifier,
                for: indexPath
            ) as! AddListingTitleTblCell
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ProductNameAndDescTblCell.identifier,
                for: indexPath
            ) as! ProductNameAndDescTblCell
            
            cell.delegateTitle = self
            cell.delegateDesc  = self
            cell.indexPath     = indexPath
            cell.addBorder(
                titleFilled: viewModel.isTitleFieldFilled,
                descFilled:  viewModel.isDescFieldFilled
            )
            
            // Pre-fill text fields if editing
            cell.txtField.text = viewModel.selectedTitle
            if viewModel.selectedDesc.isEmpty {
                cell.configurePlaceholder()
            } else {
                cell.txtViewDesc.text      = viewModel.selectedDesc
                cell.txtViewDesc.textColor = .black
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ExpandableTblCell.identifier,
                for: indexPath
            ) as! ExpandableTblCell
            cell.configure(
                title: Constants.CategoryType.category.rawValue,
                subtitles: nil,
                productCategory: viewModel.selectedCategory,
                categoryType: .category
            )
            cell.showBorder = viewModel.showRedBorderOnCategory
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ExpandableTblCell.identifier,
                for: indexPath
            ) as! ExpandableTblCell
            cell.showBorder = viewModel.showRedBorderOnSize
            cell.configure(
                title: Constants.CategoryType.size.rawValue,
                subtitles: viewModel.selectedSize,
                categoryType: .size
            )
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ExpandableTblCell.identifier,
                for: indexPath
            ) as! ExpandableTblCell
            cell.configure(
                title: Constants.CategoryType.fabric.rawValue,
                subtitles: viewModel.selectedFabric,
                categoryType: .fabric
            )
            cell.showBorder = viewModel.showRedBorderOnFabric
            return cell
            
        case 6:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ExpandableTblCell.identifier,
                for: indexPath
            ) as! ExpandableTblCell
            cell.configure(
                title: Constants.CategoryType.color.rawValue,
                subtitles: viewModel.selectedColor,
                categoryType: .color
            )
            cell.showBorder = viewModel.showRedBorderOnColor
            return cell
            
        case 7:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: ExpandableTblCell.identifier,
                for: indexPath
            ) as! ExpandableTblCell
            if let priceObj = viewModel.selectedPriceValues {
                cell.configure(
                    title: Constants.CategoryType.price.rawValue,
                    subtitles: [],
                    productCategory: nil,
                    categoryType: .price,
                    prices: priceObj
                )
            } else {
                cell.configure(
                    title: Constants.CategoryType.price.rawValue,
                    subtitles: [],
                    categoryType: .price
                )
            }
            cell.showBorder = viewModel.showRedBorderOnPrice
            return cell
            
        case 8:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: RenewalOptionsTblCell.identifier,
                for: indexPath
            ) as! RenewalOptionsTblCell
            return cell
            
        case 9:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: SaveToDraftTblCell.identifier,
                for: indexPath
            ) as! SaveToDraftTblCell
            return cell
            
        case 10:
            let cell = tableView.dequeueReusableCell(
                withIdentifier: UploadButtonTblCell.identifier,
                for: indexPath
            ) as! UploadButtonTblCell
            cell.btnUpload.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnUpload.addTarget(self,
                                     action: #selector(uploadButtonTapped(_:)),
                                     for: .touchUpInside)
            cell.btnUpload.tag = indexPath.row
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.row {
        case 3:
            // Category
            viewModel.showRedBorderOnCategory = false
            Router.showBottomSheet(from: self, bottomeSheetType: .category) { _ in
                // handled by NotificationCenter
            }
            
        case 4:
            // Size
            viewModel.showRedBorderOnSize = false
            Router.showBottomSheet(from: self, bottomeSheetType: .size) { data in
                self.viewModel.selectedSize = data
                self.tblAddProduct.reloadRows(
                    at: [IndexPath(row: 4, section: 0)],
                    with: .automatic
                )
            }
            
        case 5:
            // Fabric
            viewModel.showRedBorderOnFabric = false
            Router.showBottomSheet(from: self, bottomeSheetType: .fabric) { data in
                self.viewModel.selectedFabric = data
                self.tblAddProduct.reloadRows(
                    at: [IndexPath(row: 5, section: 0)],
                    with: .automatic
                )
            }
            
        case 6:
            // Color
            viewModel.showRedBorderOnColor = false
            Router.showBottomSheet(from: self, bottomeSheetType: .color) { data in
                self.viewModel.selectedColor = data
                self.tblAddProduct.reloadRows(
                    at: [IndexPath(row: 6, section: 0)],
                    with: .automatic
                )
            }
            
        case 7:
            // Price
            viewModel.showRedBorderOnPrice = false
            Router.showPriceBottomSheet(from: self) { priceObj in
                self.viewModel.selectedPriceValues = priceObj
                self.tblAddProduct.reloadRows(
                    at: [IndexPath(row: 7, section: 0)],
                    with: .automatic
                )
            }
            
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:  return 250
        case 9:  return 70
        case 10: return 70
        default: return UITableView.automaticDimension
        }
    }
}

// MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension AddProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func openImagePicker(for rowIndex: Int) {
        let imagePickerController        = UIImagePickerController()
        imagePickerController.delegate   = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            viewModel.imageLists.append(selectedImage)
            tblAddProduct.reloadRows(
                at: [IndexPath(row: 0, section: 0)],
                with: .automatic
            )
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - ProductTitleUpdateProtocol & ProductDescriptionUpdateProtocol
extension AddProductVC: ProductTitleUpdateProtocol, ProductDescriptionUpdateProtocol {
    
    func didUpdateTitle(text: String, at indexPath: IndexPath) {
        if text.isEmpty {
            viewModel.isTitleFieldFilled = false
        } else {
            viewModel.isTitleFieldFilled = true
        }
        viewModel.selectedTitle = text
    }
    
    func didUpdateDesc(text: String, at indexPath: IndexPath) {
        if text.isEmpty {
            viewModel.isDescFieldFilled = false
        } else {
            viewModel.isDescFieldFilled = true
        }
        viewModel.selectedDesc = text
    }
}

