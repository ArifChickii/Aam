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
import FirebaseFirestoreInternal

class AddProductVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var tblAddProduct: UITableView!
    
    /// ViewModel to handle product creation & editing
    var viewModel = AddProductViewModel()
    
    /// If this is non-nil, we are editing an existing product
    var editingProduct: ProductInfo? = nil
    
    private let merchantService = MerchantService()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndDataSources()
        registerCells()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleBottomSheetDismissedForCategory(_:)),
                                               name: .didDismissBottomSheet,
                                               object: nil)
        tblAddProduct.translatesAutoresizingMaskIntoConstraints = false
        
        // If we have a product to edit, load it now:
        if let productToEdit = editingProduct {
            // Provide a completion handler so we can reload UI after images finish downloading
            viewModel.setupEditMode(with: productToEdit) { [weak self] in
                guard let self = self else { return }
                // Reload the table or specific rows after we have old images
                DispatchQueue.main.async {
                    self.tblAddProduct.reloadData()
                }
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .didDismissBottomSheet, object: nil)
    }
    
    // MARK: - TableView Setup
    func setDelegatesAndDataSources(){
        tblAddProduct.delegate = self
        tblAddProduct.dataSource = self
    }
    
    private func registerCells() {
        tblAddProduct.register(UINib(nibName: AddPhotoTblCelll.identifier, bundle: nil), forCellReuseIdentifier: AddPhotoTblCelll.identifier)
        tblAddProduct.register(UINib(nibName: AddListingTitleTblCell.identifier, bundle: nil), forCellReuseIdentifier: AddListingTitleTblCell.identifier)
        tblAddProduct.register(UINib(nibName: ProductNameAndDescTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductNameAndDescTblCell.identifier)
        tblAddProduct.register(UINib(nibName: ExpandableTblCell.identifier, bundle: nil), forCellReuseIdentifier: ExpandableTblCell.identifier)
        tblAddProduct.register(UINib(nibName: RenewalOptionsTblCell.identifier, bundle: nil), forCellReuseIdentifier: RenewalOptionsTblCell.identifier)
        tblAddProduct.register(UINib(nibName: SaveToDraftTblCell.identifier, bundle: nil), forCellReuseIdentifier: SaveToDraftTblCell.identifier)
        tblAddProduct.register(UINib(nibName: UploadButtonTblCell.identifier, bundle: nil), forCellReuseIdentifier: UploadButtonTblCell.identifier)
        
        tblAddProduct.estimatedRowHeight = 80
        tblAddProduct.rowHeight = UITableView.automaticDimension
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        IQKeyboardManager.shared.reloadLayoutIfNeeded()
    }
    
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
            self.tblAddProduct.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
        }
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
        if self.viewModel.selectedTitle.isEmpty {
            self.viewModel.isTitleFieldFilled = false
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfTitleAndDesc], with: .automatic)
        }
        
        // Images (only required if we are creating a new product, or if we want to force user to re-select images in edit mode)
        // If your logic is: "If editing, user can keep old images even if they haven't selected new images," then skip this check in edit mode:
        if editingProduct == nil {
            // Creating new product - images must exist
            if self.viewModel.imageLists.isEmpty {
                self.viewModel.showRedBorderOnAddImage = true
                isValid = false
                self.tblAddProduct.reloadRows(at: [indexPathOfImage], with: .automatic)
            }
        }
        
        // Description
        if self.viewModel.selectedDesc.isEmpty {
            self.viewModel.isDescFieldFilled = false
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfTitleAndDesc], with: .automatic)
        }
        
        // Category
        if self.viewModel.selectedCategory == nil {
            self.viewModel.showRedBorderOnCategory = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfCategory], with: .automatic)
        }
        
        // Size
        if self.viewModel.selectedSize.isEmpty {
            self.viewModel.showRedBorderOnSize = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfSize], with: .automatic)
        }
        
        // Fabric
        if self.viewModel.selectedFabric.isEmpty {
            self.viewModel.showRedBorderOnFabric = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfFabric], with: .automatic)
        }
        
        // Color
        if self.viewModel.selectedColor.isEmpty {
            self.viewModel.showRedBorderOnColor = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfColor], with: .automatic)
        }
        
        // Price
        if self.viewModel.selectedPriceValues == nil {
            self.viewModel.showRedBorderOnPrice = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfPrice], with: .automatic)
        }
        
        return isValid
    }
    
    // MARK: - Upload/Create Button
    @objc func uploadButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        
        // 1) Validate
        if !self.validateAllFields() {
            Helper.showAlertWithOnlyOk(title: "Alert", msg: "Please fill out all fields", vc: self)
            return
        }
        
        // 2) Check if user is merchant
        LoaderManager.shared.showLoader(on: self.view, message: "Checking merchant status...")
        
        guard let currentUser = Auth.auth().currentUser else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error", msg: "User not logged in.", vc: self)
            return
        }
        
        let userRef = Firestore.firestore().collection("users").document(currentUser.uid)
        userRef.getDocument { [weak self] snapshot, error in
            guard let self = self else { return }
            LoaderManager.shared.hideLoader()
            
            if let error = error {
                Helper.showAlert(title: "Error", msg: "Failed to fetch user doc: \(error.localizedDescription)", vc: self)
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
        LoaderManager.shared.showLoader(on: self.view, message: "Creating merchant account...")
        
        guard let email = currentUser.email else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error", msg: "No email found for current user.", vc: self)
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
                        // Now proceed based on whether we are editing or creating
                        if self.editingProduct == nil {
                            self.uploadProductFlow()
                        } else {
                            self.updateProductFlow()
                        }
                    }
                }
            case .failure(let error):
                LoaderManager.shared.hideLoader()
                Helper.showAlert(title: "Error", msg: "Failed to create merchant: \(error.localizedDescription)", vc: self)
            }
        }
    }
    
    // MARK: - CREATE (Upload New Product)
    /// Creates a brand-new product
    private func uploadProductFlow() {
        LoaderManager.shared.showLoader(on: self.view, message: "Uploading Product, please wait...")
        
        // 1. Upload images to Firebase
        viewModel.uploadImagesToFirebase(images: viewModel.imageLists) { [weak self] imgUrls in
            guard let self = self else { return }
            print("Uploaded images: \(imgUrls)")
            
            // 2. Create ProductInfo
            if let newProduct = self.viewModel.createProductInfo(with: imgUrls) {
                // 3. Save the product in Firestore
                self.viewModel.addProductToFirebase(productObj: newProduct) { generatedID in
                    LoaderManager.shared.hideLoader()
                    if generatedID.contains("Failed") {
                        Helper.showAlert(title: "Error", msg: generatedID, vc: self)
                    } else {
                        Helper.shared.showToast(message: "Product uploaded successfully!", vc: self)
                        Router.dismiss(from: self)
                    }
                }
            } else {
                LoaderManager.shared.hideLoader()
                Helper.showAlert(title: "Error", msg: "Failed to create product information.", vc: self)
            }
        }
    }
    
    // MARK: - UPDATE (Edit existing Product)
    /// Updates an existing product
    private func updateProductFlow() {
        LoaderManager.shared.showLoader(on: self.view, message: "Updating Product, please wait...")
        
        guard let editingProduct = editingProduct else {
            LoaderManager.shared.hideLoader()
            Helper.showAlert(title: "Error", msg: "No product to edit.", vc: self)
            return
        }
        
        if viewModel.imageLists.isEmpty {
            // If user did NOT pick any new images, we keep the old images
            self.doUpdateProductFlow(withImageURLs: editingProduct.images ?? [])
        } else {
            // If user selected new images, re-upload them and discard old ones
            viewModel.uploadImagesToFirebase(images: viewModel.imageLists) { [weak self] imgUrls in
                guard let self = self else { return }
                self.doUpdateProductFlow(withImageURLs: imgUrls)
            }
        }
    }
    
    /// Actually commits the updated product data to Firestore
    private func doUpdateProductFlow(withImageURLs imageURLs: [String]) {
        LoaderManager.shared.showLoader(on: self.view, message: "Finalizing update...")
        
        guard var editingProduct = editingProduct else { return }
        
        // Overwrite fields from the UI
        editingProduct.title       = viewModel.selectedTitle
        editingProduct.description = viewModel.selectedDesc
        editingProduct.images      = imageURLs
        editingProduct.sizes       = viewModel.selectedSize
        editingProduct.colors      = viewModel.selectedColor
        editingProduct.fabrics     = viewModel.selectedFabric
        editingProduct.category    = viewModel.selectedCategory
        editingProduct.price       = viewModel.selectedPriceValues?.price
        editingProduct.cutPrice    = viewModel.selectedPriceValues?.cutPrice
        
        // Send to view model
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
    
    // MARK: - Actions
    @IBAction func crossAction(){
        Router.dismiss(from: self)
    }
}

// MARK: - TableView
extension AddProductVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddPhotoTblCelll.identifier, for: indexPath) as! AddPhotoTblCelll
            cell.configure(images: viewModel.imageLists)
            cell.showBorder = self.viewModel.showRedBorderOnAddImage
            cell.onAddImageTapped = { [weak self] in
                guard let self = self else { return }
                self.viewModel.showRedBorderOnAddImage = false
                // If user has < 7 images, let them pick more
                if self.viewModel.imageLists.count < 7 {
                    self.openImagePicker(for: indexPath.row)
                } else {
                    Helper.showAlert(title: "Alert", msg: StringConstants.maxImagesReached, vc: self)
                }
            }
            return cell
            
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddListingTitleTblCell.identifier, for: indexPath) as! AddListingTitleTblCell
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductNameAndDescTblCell.identifier, for: indexPath) as! ProductNameAndDescTblCell
            cell.delegateTitle = self
            cell.delegateDesc  = self
            cell.indexPath     = indexPath
            cell.addBorder(titleFilled: self.viewModel.isTitleFieldFilled,
                           descFilled:  self.viewModel.isDescFieldFilled)
            
            // Pre-fill text fields if editing
            cell.txtField.text = viewModel.selectedTitle
            if viewModel.selectedDesc.isEmpty {
                // If no description, show placeholder
                cell.configurePlaceholder()
            } else {
                cell.txtViewDesc.text = viewModel.selectedDesc
                cell.txtViewDesc.textColor = .black
            }
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.category.rawValue,
                           subtitles: nil,
                           productCategory: self.viewModel.selectedCategory,
                           categoryType: .category)
            cell.showBorder = self.viewModel.showRedBorderOnCategory
            return cell
            
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.showBorder = self.viewModel.showRedBorderOnSize
            cell.configure(title: Constants.CategoryType.size.rawValue,
                           subtitles: viewModel.selectedSize,
                           categoryType: .size)
            return cell
            
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.fabric.rawValue,
                           subtitles: viewModel.selectedFabric,
                           categoryType: .fabric)
            cell.showBorder = self.viewModel.showRedBorderOnFabric
            return cell
            
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.color.rawValue,
                           subtitles: viewModel.selectedColor,
                           categoryType: .color)
            cell.showBorder = self.viewModel.showRedBorderOnColor
            return cell
            
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            
            if let priceObj = self.viewModel.selectedPriceValues {
                cell.configure(title: Constants.CategoryType.price.rawValue,
                               subtitles: [],
                               productCategory: nil,
                               categoryType: .price,
                               prices: priceObj)
            } else {
                cell.configure(title: Constants.CategoryType.price.rawValue,
                               subtitles: [],
                               categoryType: .price)
            }
            cell.showBorder = self.viewModel.showRedBorderOnPrice
            return cell
            
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: RenewalOptionsTblCell.identifier, for: indexPath) as! RenewalOptionsTblCell
            return cell
            
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: SaveToDraftTblCell.identifier, for: indexPath) as! SaveToDraftTblCell
            return cell
            
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: UploadButtonTblCell.identifier, for: indexPath) as! UploadButtonTblCell
            cell.btnUpload.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnUpload.addTarget(self, action: #selector(uploadButtonTapped(_:)), for: .touchUpInside)
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
            self.viewModel.showRedBorderOnCategory = false
            Router.showBottomSheet(from: self, bottomeSheetType: .category) { data in
                // not used here, we handle via notification
            }
            
        case 4:
            // Size
            self.viewModel.showRedBorderOnSize = false
            Router.showBottomSheet(from: self,bottomeSheetType: .size) { data in
                self.viewModel.selectedSize = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
            }
            
        case 5:
            // Fabric
            self.viewModel.showRedBorderOnFabric = false
            Router.showBottomSheet(from: self,bottomeSheetType: .fabric) { data in
                self.viewModel.selectedFabric = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
            }
            
        case 6:
            // Color
            self.viewModel.showRedBorderOnColor = false
            Router.showBottomSheet(from: self,bottomeSheetType: .color) { data in
                self.viewModel.selectedColor = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
            }
            
        case 7:
            // Price
            self.viewModel.showRedBorderOnPrice = false
            Router.showPriceBottomSheet(from: self) { priceObj in
                self.viewModel.selectedPriceValues = priceObj
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .automatic)
            }
            
        default:
            // do nothing
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

// MARK: - Image Picker
extension AddProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func openImagePicker(for rowIndex: Int) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate   = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.view.tag   = rowIndex // optional usage
        present(imagePickerController, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            viewModel.imageLists.append(selectedImage)
            tblAddProduct.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
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
            self.viewModel.isTitleFieldFilled = false
        } else {
            self.viewModel.isTitleFieldFilled = true
        }
        self.viewModel.selectedTitle = text
    }
    
    func didUpdateDesc(text: String, at indexPath: IndexPath) {
        if text.isEmpty {
            self.viewModel.isDescFieldFilled = false
        } else {
            self.viewModel.isDescFieldFilled = true
        }
        self.viewModel.selectedDesc = text
    }
}

