//
//  SellerHubVc.swift
//  AAM
//
//  Created by Arif on 25/12/2024.
//

import UIKit

class SellerHubVc: UIViewController, Storyboarded {
    @IBOutlet weak var tableView: UITableView!
    
    private let viewModel = SellerHubViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupTableView()
        registerCells()
        
        // 1) Fetch the stats for current user
        //    On completion => reload table so the updated stats show
        viewModel.fetchSellerStats { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
    }
    
    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate   = self
    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: SellerHubDashboardTblCell.identifier, bundle: nil),
                           forCellReuseIdentifier: SellerHubDashboardTblCell.identifier)
        tableView.register(UINib(nibName: SellerHubItemsTblCell.identifier, bundle: nil),
                           forCellReuseIdentifier: SellerHubItemsTblCell.identifier)
    }
}

// MARK: - UITableViewDataSource
extension SellerHubVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let sectionType = viewModel.sectionType(for: indexPath)
        
        switch sectionType {
        case .dashboard(let dashboardData):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SellerHubDashboardTblCell.identifier,
                for: indexPath
            ) as? SellerHubDashboardTblCell else {
                return UITableViewCell()
            }
            cell.configure(with: dashboardData)
            return cell
            
        case .item(let itemData):
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: SellerHubItemsTblCell.identifier,
                for: indexPath
            ) as? SellerHubItemsTblCell else {
                return UITableViewCell()
            }
            cell.configure(with: itemData)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SellerHubVc: UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        let sectionType = viewModel.sectionType(for: indexPath)
        switch sectionType {
        case .dashboard(_):
            // e.g., show Seller Profile
            break
        case .item(let itemData):
            // handle row
            if itemData.title.lowercased() == "profile" {
                Router.showSellerProfileVC(from: self)
            } else if itemData.title.lowercased() == "view listings" {
                Router.showSellerListingsVc(from: self)
            } else if itemData.title == "Sold Items" {
                Router.showSoldItemsVc(from: self)
            }
        }
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            // Dashboard cell
            return 240
        } else {
            // Other items
            return 100
        }
    }
}

