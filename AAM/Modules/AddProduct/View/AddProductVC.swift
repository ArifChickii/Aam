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
         let category = userInfo["category"] as? ProductCategory, let  subcategory = userInfo["subcategory"] as? String {
             print("Received data: \(category) and subcategory \(subcategory)")
             
             // Handle the data received from the BottomSheetVC
             self.viewModel.selectedCategory = "\(category.title ?? "") -> \(subcategory)"
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
    
    @IBAction func backAction(){
        Router.pop(from: self)
    }

}


// MARK: UITableView
extension AddProductVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.courseList.count
        return 11
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddPhotoTblCelll.identifier, for: indexPath) as! AddPhotoTblCelll

            cell.configure(images: viewModel.imageLists)
            cell.onAddImageTapped = { [weak self] in
                if self?.viewModel.imageLists.count ?? 0 < 4{
                    self?.openImagePicker(for: indexPath.row)
                }
                
            }
            
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: AddListingTitleTblCell.identifier, for: indexPath) as! AddListingTitleTblCell
//            cell.configure(obj: viewModel.product)
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: ProductNameAndDescTblCell.identifier, for: indexPath) as! ProductNameAndDescTblCell
           
//            cell.configure(obj: viewModel.product)
            return cell
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.category.rawValue, subtitle: self.viewModel.selectedCategory)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.size.rawValue, subtitle: viewModel.selectedSize)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.fabric.rawValue, subtitle: viewModel.selectedFabric)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.color.rawValue, subtitle: viewModel.selectedColor)
            return cell
       
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.price.rawValue, subtitle: "Please select price")
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
//            cell.configure(obj: viewModel.product)
            return cell
        default:
            return UITableViewCell()
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

            Router.showBottomSheet(from: self, bottomeSheetType: Constants.CategoryType.category) { [weak self] data in
                print("category data recieved in notification observer")
            }
            
            
            
        case 4:
            print("Size")
            Router.showBottomSheet(from: self,bottomeSheetType: Constants.CategoryType.size, onDataPass: {data in
                print("selected size is \(data)")
                self.viewModel.selectedSize = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 4, section: 0)], with: .automatic)
            })
        case 5:
            print("fabric")
            Router.showBottomSheet(from: self,bottomeSheetType: Constants.CategoryType.fabric, onDataPass: {data in
                print("selected fabric is \(data)")
                self.viewModel.selectedFabric = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 5, section: 0)], with: .automatic)
                
            })
        case 6:
            print("Color")
            Router.showBottomSheet(from: self,bottomeSheetType: Constants.CategoryType.color, onDataPass: {data in
                print("selected colors are \(data)")
                self.viewModel.selectedColor = data
                self.tblAddProduct.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
            })
        case 7:
            print("price")
        case 8:
            print("do nothing")
        case 9:
            print("do nothing")
           
            
        case 10:
            print("do nothing")
           
            viewModel.addProductToFirebase()
                   
                
            

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

