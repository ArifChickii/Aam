//
//  AddProductVC.swift
//  AAM
//
//  Created by Mac on 04/09/2024.
//

import UIKit
import FittedSheets




class AddProductVC: UIViewController, Storyboarded {
    
    
    
    @IBOutlet weak var tblAddProduct: UITableView!

    
    
    var viewModel = AddProductViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
        NotificationCenter.default.addObserver(self, selector: #selector(handleBottomSheetDismissedForCategory(_:)), name: .didDismissBottomSheet, object: nil)
    }
    
    
    @objc func handleBottomSheetDismissedForCategory(_ notification: Notification) {
        if let userInfo = notification.userInfo,
         let category = userInfo["category"] as? ProductCategoryForDataRecieving, let  subcategory = userInfo["subcategory"] as? DropDown {
             print("Received data: \(category) and subcategory \(subcategory)")
            let prodCategory = ProductCategory(title: category.title ?? "", subCategories: [subcategory.title ?? ""])
            self.viewModel.selectedCategory = prodCategory
             // Handle the data received from the BottomSheetVC
             self.tblAddProduct.reloadRows(at: [IndexPath(row: 3, section: 0)], with: .automatic)
         }
     }
    
    deinit {
            // Remove observer when the controller is deallocated
            NotificationCenter.default.removeObserver(self, name: .didDismissBottomSheet, object: nil)
        }

    
    
    func setDelegatesAndDataSources(){
        
        tblAddProduct.delegate = self
        tblAddProduct.dataSource = self
    }
    
    private func registerCells() {
        
        tblAddProduct.register(UINib(nibName: AddPhotoTblCelll.identifier, bundle: nil), forCellReuseIdentifier: AddPhotoTblCelll.identifier)
//        add listing part
        tblAddProduct.register(UINib(nibName: AddListingTitleTblCell.identifier, bundle: nil), forCellReuseIdentifier: AddListingTitleTblCell.identifier)
        //        name and description fields part
        tblAddProduct.register(UINib(nibName: ProductNameAndDescTblCell.identifier, bundle: nil), forCellReuseIdentifier: ProductNameAndDescTblCell.identifier)
        //       categories part
        tblAddProduct.register(UINib(nibName: ExpandableTblCell.identifier, bundle: nil), forCellReuseIdentifier: ExpandableTblCell.identifier)
        //        renewal radio buttons part
        tblAddProduct.register(UINib(nibName: RenewalOptionsTblCell.identifier, bundle: nil), forCellReuseIdentifier: RenewalOptionsTblCell.identifier)
        //        save to draft button part
        tblAddProduct.register(UINib(nibName: SaveToDraftTblCell.identifier, bundle: nil), forCellReuseIdentifier: SaveToDraftTblCell.identifier)
        //        upload button part
        tblAddProduct.register(UINib(nibName: UploadButtonTblCell.identifier, bundle: nil), forCellReuseIdentifier: UploadButtonTblCell.identifier)
        
        tblAddProduct.estimatedRowHeight = 80
        tblAddProduct.rowHeight = UITableView.automaticDimension
    }
    
    func saveTitleAndDescriptionToModel() {
        let indexPath = IndexPath(row: 2, section: 0) // Specify the row and section you need
            if let cell = tblAddProduct.cellForRow(at: indexPath) as? ProductNameAndDescTblCell {
                // Access the cell's content
                let title = cell.txtField.text
                let descriptionstr = cell.txtViewDesc.text
                print("Title: \(title ?? ""), Description: \(description ?? "")")
                self.viewModel.selectedTitle = title ?? ""
                self.viewModel.selectedDesc = descriptionstr ?? ""
            }
        
    }
    
//    @IBAction func backAction(){
//        Router.pop(from: self)
//    }
    
    func validateAllFields() -> Bool{
        
        var isValid = true
        let indexPathOfImage = IndexPath(row: 1, section: 0)
        let indexPathOfTitleAndDesc = IndexPath(row: 2, section: 0)
        let indexPathOfCategory = IndexPath(row: 3, section: 0)
        let indexPathOfSize = IndexPath(row: 4, section: 0)
        let indexPathOfFabric = IndexPath(row: 5, section: 0)
        let indexPathOfColor = IndexPath(row: 6, section: 0)
        let indexPathOfPrice = IndexPath(row: 7, section: 0)
        
        
        if self.viewModel.selectedTitle.elementsEqual(""){
            self.viewModel.isTitleFieldFilled = false
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfTitleAndDesc], with: .automatic)
        }
        if self.viewModel.imageLists.count == 0{
            self.viewModel.showRedBorderOnAddImage = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfImage], with: .automatic)
        }
        
        if self.viewModel.selectedDesc.elementsEqual(""){
            self.viewModel.isDescFieldFilled = false
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfTitleAndDesc], with: .automatic)
        }
        if self.viewModel.selectedCategory == nil{
            self.viewModel.showRedBorderOnCategory = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfCategory], with: .automatic)
        }
        if self.viewModel.selectedSize.count == 0{
            self.viewModel.showRedBorderOnSize = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfSize], with: .automatic)
        }
        if self.viewModel.selectedFabric.count == 0{
            self.viewModel.showRedBorderOnFabric = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfFabric], with: .automatic)
        }
        
        if self.viewModel.selectedColor.count == 0{
            self.viewModel.showRedBorderOnColor = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfColor], with: .automatic)
        }
        if self.viewModel.selectedPriceValues == nil{
            self.viewModel.showRedBorderOnPrice = true
            isValid = false
            self.tblAddProduct.reloadRows(at: [indexPathOfPrice], with: .automatic)
        }
        
        
        return isValid
    }
    
    
    

}
extension AddProductVC: ProductTitleUpdateProtocol, ProductDescriptionUpdateProtocol{
    func didUpdateDesc(text: String, at indexPath: IndexPath) {
        if text.elementsEqual(""){
            self.viewModel.isDescFieldFilled = false
        }else{
            self.viewModel.isDescFieldFilled = true
        }
        self.viewModel.selectedDesc = text
    }
    
    func didUpdateTitle(text: String, at indexPath: IndexPath) {
        if text.elementsEqual(""){
            self.viewModel.isTitleFieldFilled = false
        }else{
            self.viewModel.isTitleFieldFilled = true
        }
        self.viewModel.selectedTitle = text
    }
    
    
}

// MARK: UITableView
extension AddProductVC: UITableViewDelegate, UITableViewDataSource{
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddPhotoTblCelll.identifier, for: indexPath) as! AddPhotoTblCelll

            cell.configure(images: viewModel.imageLists)
            cell.showBorder = self.viewModel.showRedBorderOnAddImage
            cell.onAddImageTapped = { [weak self] in
                self?.viewModel.showRedBorderOnAddImage = false
                if self?.viewModel.imageLists.count ?? 0 < 7{
                    self?.openImagePicker(for: indexPath.row)
                }else{
                    Helper.showAlert(title: "Alert", msg: StringConstants.maxImagesReached, vc: self!)
                }
                
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddListingTitleTblCell.identifier, for: indexPath) as! AddListingTitleTblCell
//            cell.configure(obj: viewModel.product)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductNameAndDescTblCell.identifier, for: indexPath) as! ProductNameAndDescTblCell
            cell.delegateTitle = self // Set the delegate
            cell.delegateDesc = self
            cell.indexPath = indexPath
            cell.addBorder(titleFilled: self.viewModel.isTitleFieldFilled, descFilled: self.viewModel.isDescFieldFilled)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.category.rawValue, subtitles: nil, productCategory: self.viewModel.selectedCategory, categoryType: .category)
            cell.showBorder = self.viewModel.showRedBorderOnCategory
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.showBorder = self.viewModel.showRedBorderOnSize
            cell.configure(title: Constants.CategoryType.size.rawValue, subtitles: viewModel.selectedSize, categoryType: .size)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.fabric.rawValue, subtitles: viewModel.selectedFabric, categoryType: .fabric)
            cell.showBorder = self.viewModel.showRedBorderOnFabric
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.color.rawValue, subtitles: viewModel.selectedColor, categoryType: .color)
            cell.showBorder = self.viewModel.showRedBorderOnColor
            return cell
       
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            if let priceObj = self.viewModel.selectedPriceValues{
                cell.configure(title: Constants.CategoryType.price.rawValue, subtitles: [String](), categoryType: .price, prices: priceObj)
            }else{
                cell.configure(title: Constants.CategoryType.price.rawValue, subtitles: [String](), categoryType: .price)
            }
            cell.showBorder = self.viewModel.showRedBorderOnPrice
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: RenewalOptionsTblCell.identifier, for: indexPath) as! RenewalOptionsTblCell
//            cell.configure(obj: viewModel.product)
            return cell
        case 9:
            let cell = tableView.dequeueReusableCell(withIdentifier: SaveToDraftTblCell.identifier, for: indexPath) as! SaveToDraftTblCell
            
//            cell.configure(obj: viewModel.product)
            return cell
        case 10:
            let cell = tableView.dequeueReusableCell(withIdentifier: UploadButtonTblCell.identifier, for: indexPath) as! UploadButtonTblCell
            cell.btnUpload.removeTarget(nil, action: nil, for: .allEvents)
            cell.btnUpload.addTarget(self, action: #selector(uploadButtonTapped(_:)), for: .touchUpInside)
            cell.btnUpload.tag = indexPath.row
//            cell.configure(obj: viewModel.product)
            return cell
        default:
            return UITableViewCell()
        }
        
        
    }
    
    @objc func uploadButtonTapped(_ sender: UIButton) {
        self.view.endEditing(true)
        if !self.validateAllFields(){
            Helper.showAlertWithOnlyOk(title: "Alert", msg: "Please fill out all fields", vc: self)
            
        }else{
            
            
            let rowIndex = sender.tag
            print("Button tapped in row: \(rowIndex)")
            // Handle your button action here
            LoaderManager.shared.showLoader(on: self.view, message: "Uploading Product, please wait a few moments...")
            self.saveTitleAndDescriptionToModel()
            viewModel.uploadImagesToFirebase(images: self.viewModel.imageLists) { imgUrls in
                print(imgUrls)
                let newProduct = ProductInfo(id: UUID().uuidString, images: imgUrls, sizes: self.viewModel.selectedSize, colors: self.viewModel.selectedColor, fabrics: self.viewModel.selectedFabric, category: self.viewModel.selectedCategory, title: self.viewModel.selectedTitle, description: self.viewModel.selectedDesc, price: self.viewModel.selectedPriceValues?.price ?? "", rating: "", cutPrice: self.viewModel.selectedPriceValues?.cutPrice ?? "")
                self.viewModel.addProductToFirebase(productObj: newProduct) { str in
                    LoaderManager.shared.hideLoader()
                    Router.pop(from: self)
                }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 250
        case 1:
            return UITableView.automaticDimension
        case 2:
            return UITableView.automaticDimension
        case 3:
            return UITableView.automaticDimension
        case 4:
            return UITableView.automaticDimension
        case 5:
            return UITableView.automaticDimension
        case 6:
            return UITableView.automaticDimension
        case 7:
            return UITableView.automaticDimension
        case 8:
            return UITableView.automaticDimension
        case 9:
            return 70
        case 10:
            return 70
        
        default:
            return 0
        }
    
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
           print("do nothing")
        case 1:
            print("do nothing")
        case 2:
            print("do nothing")
        case 3:
            print("Category")
            self.viewModel.showRedBorderOnCategory = false
            Router.showBottomSheet(from: self, bottomeSheetType: Constants.CategoryType.category) { [weak self] data in
                print("category data recieved in notification observer")
                
            }
            
            
            
        case 4:
            print("Size")
            self.viewModel.showRedBorderOnSize = false
            Router.showBottomSheet(from: self,bottomeSheetType: Constants.CategoryType.size, onDataPass: {data in
                print("selected size is \(data)")
                self.viewModel.selectedSize = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
            })
        case 5:
            print("fabric")
            self.viewModel.showRedBorderOnFabric = false
            Router.showBottomSheet(from: self,bottomeSheetType: Constants.CategoryType.fabric, onDataPass: {data in
                print("selected fabric is \(data)")
                self.viewModel.selectedFabric = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
                
            })
        case 6:
            print("Color")
            self.viewModel.showRedBorderOnColor = false
            Router.showBottomSheet(from: self,bottomeSheetType: Constants.CategoryType.color, onDataPass: {data in
                print("selected colors are \(data)")
                self.viewModel.selectedColor = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
            })
        case 7:
            print("price")
            self.viewModel.showRedBorderOnPrice = false
            Router.showPriceBottomSheet(from: self) { priceObj in

                self.viewModel.selectedPriceValues = priceObj
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 7, section: 0)], with: .automatic)
            }
        case 8:
            print("do nothing")
        case 9:
            print("do nothing")
           
            
        case 10:
            print("do nothing")
            
           
            
                   
                
            

        default:
            print("do nothing")
        }
    }
    
}
// MARK: - Image Picker
extension AddProductVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func openImagePicker(for rowIndex: Int) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.view.tag = rowIndex // Tag to know which row is being updated
        present(imagePickerController, animated: true, completion: nil)
    }
    // MARK: - UIImagePickerControllerDelegate
       func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
           if let selectedImage = info[.originalImage] as? UIImage {
               viewModel.imageLists.append(selectedImage)
               tblAddProduct.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
           }
           picker.dismiss(animated: true, completion: nil)
       }

       func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
           picker.dismiss(animated: true, completion: nil)
       }
}

