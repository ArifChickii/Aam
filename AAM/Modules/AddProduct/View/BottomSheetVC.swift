//
//  BottomSheetVC.swift
//  AAM
//  Created by Mac on 11/09/2024.
//

import UIKit

class BottomSheetVC: UIViewController, Storyboarded {
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    var bottomSheetType : Constants.CategoryType?
    var bottomSheetList = [DropDown]()
    var categoriesList = [ProductCategory]()
    var selectedCategory : ProductCategory?
    var onDataPass: (([DropDown]) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
        
    }
    
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Ensure the layout is updated
        self.view.layoutIfNeeded()
        
        // Calculate the dynamic size based on the main view of the view controller
        let targetSize = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        // Set the preferred content size for the bottom sheet
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: targetSize.height)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbl.translatesAutoresizingMaskIntoConstraints = false
        if let navigationController = self.navigationController{
            navigationController.navigationBar.isHidden = true
        }
        
        
        self.setupData()
    }
    
    
    func setupData(){
        if let categoryType = self.bottomSheetType{
            switch categoryType {
            case Constants.CategoryType.category:
                self.categoriesList = Constants.shared.categoriesList
                self.lblTitle.text = "Select category"
                self.btnSave.isHidden = true
            case Constants.CategoryType.subCategory:
                self.categoriesList = Constants.shared.categoriesList
                self.bottomSheetList = self.selectedCategory?.subCategories ?? []
                self.lblTitle.text = "\(self.selectedCategory?.title ?? "Select subcategory")"
                self.btnSave.isHidden = true
            case Constants.CategoryType.size:
                self.bottomSheetList =  Constants.shared.sizesList
                self.lblTitle.text = "Select size"
                self.btnSave.isHidden = false
            case Constants.CategoryType.color:
                self.bottomSheetList =  Constants.shared.colorsList
                self.lblTitle.text = "Select color"
                self.btnSave.isHidden = false
            case Constants.CategoryType.fabric:
                self.bottomSheetList =  Constants.shared.fabricList
                self.lblTitle.text = "Select fabric"
                self.btnSave.isHidden = false
            default:
                self.bottomSheetList =  Constants.shared.colorsList
                self.lblTitle.text = "Select color"
                self.btnSave.isHidden = false
            }
        }
        self.tbl.reloadData()
    }
    
    
    
    func setDelegatesAndDataSources(){
        
        tbl.delegate = self
        tbl.dataSource = self
    }
    
    private func registerCells() {
        
        tbl.register(UINib(nibName: BottomSheetTblCell.identifier, bundle: nil), forCellReuseIdentifier: BottomSheetTblCell.identifier)
        tbl.estimatedRowHeight = 40
        tbl.rowHeight = UITableView.automaticDimension
    }

    @IBAction func saveAction(){
//
        if self.bottomSheetType != .category || self.bottomSheetType != .subCategory{
            let selectedItems = self.bottomSheetList.filter { $0.isChecked ?? false }
            onDataPass?(selectedItems)
            self.dismiss(animated: true)
        }else{
//            do nothing
        }
        
        
    }
   

}
extension BottomSheetVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        if self.bottomSheetType != Constants.CategoryType.category{
            return self.bottomSheetList.count
        }
        return self.categoriesList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BottomSheetTblCell.identifier, for: indexPath) as! BottomSheetTblCell
        if self.bottomSheetType == Constants.CategoryType.category{
            let item = self.categoriesList[indexPath.row]
            cell.configure(objCategory: item, type: self.bottomSheetType ?? .category)
        }else{
            let item = self.bottomSheetList[indexPath.row]
            cell.configure(obj: item, type: self.bottomSheetType ?? .color)
        }
        
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if let categoryType = self.bottomSheetType{
            switch categoryType {
            case Constants.CategoryType.category:
                Router.MoveToBottomSheetAsNavigation(from: self, bottomeSheetType: Constants.CategoryType.subCategory, selectedCategor: self.categoriesList[indexPath.row])
            case Constants.CategoryType.subCategory:
//              move to previous screen
                NotificationCenter.default.post(name: .didDismissBottomSheet, object: nil, userInfo: ["category": self.selectedCategory,
                    "subcategory": self.bottomSheetList[indexPath.row]])
                self.dismiss(animated: true)
            case Constants.CategoryType.size:
                self.toggleCheck(for: indexPath)
            case Constants.CategoryType.color:
                self.toggleCheck(for: indexPath)
            case Constants.CategoryType.fabric:
                self.toggleCheck(for: indexPath)
            default:
                self.toggleCheck(for: indexPath)
            }
        }
    }
    
    
    
    func toggleCheck(for index: IndexPath){
        self.bottomSheetList[index.row].isChecked = !(bottomSheetList[index.row].isChecked ?? false)
        tbl.reloadRows(at: [index], with: .automatic)
    }
    
}

