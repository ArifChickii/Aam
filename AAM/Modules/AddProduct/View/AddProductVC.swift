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
        return 10
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
            cell.configure(title: Constants.CategoryType.category.rawValue)
            return cell
        case 4:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.size.rawValue)
            return cell
        case 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.color.rawValue)
            return cell
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: ExpandableTblCell.identifier, for: indexPath) as! ExpandableTblCell
            cell.configure(title: Constants.CategoryType.price.rawValue)
            return cell
        case 7:
            let cell = tableView.dequeueReusableCell(withIdentifier: RenewalOptionsTblCell.identifier, for: indexPath) as! RenewalOptionsTblCell
//            cell.configure(obj: viewModel.product)
            return cell
        case 8:
            let cell = tableView.dequeueReusableCell(withIdentifier: SaveToDraftTblCell.identifier, for: indexPath) as! SaveToDraftTblCell
//            cell.configure(obj: viewModel.product)
            return cell
        case 9:
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
            return 70
        case 9:
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
            Router.OpenBottomSheet(from: self)
        case 4:
            print("Size")
        case 5:
            print("Color")
        case 6:
            print("price")
        case 7:
            print("do nothing")
        case 8:
            print("do nothing")
        case 9:
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
