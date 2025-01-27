//
//  BottomSheetVC.swift
//  AAM
//
//  Created by Mac on 11/09/2024.
//

import UIKit

class BottomSheetVC: UIViewController, Storyboarded {
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var btnSave: UIButton!
    @IBOutlet weak var btnBack: UIButton!
    
    var bottomSheetType : Constants.CategoryType?
    var bottomSheetList = [DropDown]()                // For size/color/fabric subcats
    var categoriesList = [ProductCategoryForDataRecieving]() // For categories
    var selectedCategory : ProductCategoryForDataRecieving?
    
    /// Callback to pass selected data back to AddProductVC
    var onDataPass: (([String]) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDelegatesAndDataSources()
        registerCells()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Ensure layout is updated
        self.view.layoutIfNeeded()
        
        // Calculate the dynamic size based on the main view
        let targetSize = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        // Set preferred size for the bottom sheet
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: targetSize.height)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tbl.translatesAutoresizingMaskIntoConstraints = false
        
        // Hide the navigation bar if using a nav controller
        if let navigationController = self.navigationController {
            navigationController.navigationBar.isHidden = true
        }
        
        self.setupData()
    }
    
    // MARK: - Setup Data
    private func setupData() {
        guard let categoryType = self.bottomSheetType else { return }
        self.btnBack.isHidden = true
        switch categoryType {
            
        case .category:
            // Show main categories
            self.categoriesList = Constants.shared.categoriesList
            self.lblTitle.text  = "Select category"
            self.btnSave.isHidden = true
            
        case .subCategory:
            // Navigate from category to subcategory
            self.categoriesList    = Constants.shared.categoriesList
            self.bottomSheetList   = self.selectedCategory?.subCategories ?? []
            self.lblTitle.text     = "\(self.selectedCategory?.title ?? "Select subcategory")"
            self.btnSave.isHidden  = true
            self.btnBack.isHidden = false
            
        case .size:
            // Single-select
            self.bottomSheetList = Constants.shared.sizesList
            self.lblTitle.text   = "Select size"
            self.btnSave.isHidden = false
            
        case .color:
            // Multi-select
            self.bottomSheetList = Constants.shared.colorsList
            self.lblTitle.text   = "Select color"
            self.btnSave.isHidden = false
            
        case .fabric:
            // Multi-select
            self.bottomSheetList = Constants.shared.fabricList
            self.lblTitle.text   = "Select fabric"
            self.btnSave.isHidden = false
            
        default:
            // Fallback
            self.bottomSheetList = Constants.shared.colorsList
            self.lblTitle.text   = "Select color"
            self.btnSave.isHidden = false
        }
        
        self.tbl.reloadData()
    }
    
    // MARK: - Setup
    private func setDelegatesAndDataSources() {
        tbl.delegate   = self
        tbl.dataSource = self
    }
    
    private func registerCells() {
        tbl.register(UINib(nibName: BottomSheetTblCell.identifier, bundle: nil),
                     forCellReuseIdentifier: BottomSheetTblCell.identifier)
        tbl.estimatedRowHeight = 40
        tbl.rowHeight          = UITableView.automaticDimension
    }
    
    // MARK: - Action
    @IBAction func saveAction() {
        // Only do something if NOT category or subCategory
        // because category & subCategory are handled differently
        if self.bottomSheetType != .category && self.bottomSheetType != .subCategory {
            // Gather selected items
            let selectedItems = self.bottomSheetList.filter { $0.isChecked ?? false }
            let selectedItemStrings: [String] = selectedItems.map { $0.title ?? "" }
            
            onDataPass?(selectedItemStrings)
            self.dismiss(animated: true)
        }
    }
    
    @IBAction func backAction(){
        self.navigationController?.popViewController(animated: true)
    }
}

// MARK: - UITableView
extension BottomSheetVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // If category, show categoriesList
        if self.bottomSheetType == .category {
            return self.categoriesList.count
        } else {
            return self.bottomSheetList.count
        }
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BottomSheetTblCell.identifier,
                                                 for: indexPath) as! BottomSheetTblCell
        
        if self.bottomSheetType == .category {
            let item = self.categoriesList[indexPath.row]
            cell.configure(objCategory: item,
                           type: self.bottomSheetType ?? .category)
        } else {
            let item = self.bottomSheetList[indexPath.row]
            cell.configure(obj: item,
                           type: self.bottomSheetType ?? .color)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        guard let categoryType = self.bottomSheetType else { return }
        
        switch categoryType {
        case .category:
            // Navigate to subcategory
            let selectedCat = self.categoriesList[indexPath.row]
            Router.MoveToBottomSheetAsNavigation(from: self,
                                                 bottomeSheetType: .subCategory,
                                                 selectedCategor: selectedCat)
            
        case .subCategory:
            // Post notification and dismiss
            NotificationCenter.default.post(
                name: .didDismissBottomSheet,
                object: nil,
                userInfo: [
                    "category": self.selectedCategory ?? "",
                    "subcategory": self.bottomSheetList[indexPath.row]
                ]
            )
            self.dismiss(animated: true)
            
        case .size:
            // SINGLE SELECTION for size
            toggleCheck(for: indexPath, allowMultiple: false)
            
        case .color:
            // MULTIPLE SELECTION for color
            toggleCheck(for: indexPath, allowMultiple: true)
            
        case .fabric:
            // MULTIPLE SELECTION for fabric
            toggleCheck(for: indexPath, allowMultiple: true)
            
        default:
            // fallback
            toggleCheck(for: indexPath, allowMultiple: true)
        }
    }
    
    private func toggleCheck(for index: IndexPath, allowMultiple: Bool) {
        if allowMultiple {
            // Just flip the selected row’s isChecked
            self.bottomSheetList[index.row].isChecked = !(bottomSheetList[index.row].isChecked ?? false)
        } else {
            // SINGLE selection
            // First uncheck all
            for i in 0..<bottomSheetList.count {
                bottomSheetList[i].isChecked = false
            }
            // Now check only the selected index
            self.bottomSheetList[index.row].isChecked = true
        }
        
        tbl.reloadData()
    }
}

