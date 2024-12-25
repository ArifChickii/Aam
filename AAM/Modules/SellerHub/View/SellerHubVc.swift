//
//  SellerHubVc.swift
//  AAM
//
//  Created by Arif on 25/12/2024.
//

import UIKit

class SellerHubVc: UIViewController, Storyboarded {
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    // MARK: - Properties
    private let viewModel = SellerHubViewModel()
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
        registerCells()
    }
    
    // MARK: - Private Methods
    private func setupTableView() {

        
        tableView.dataSource = self
        tableView.delegate   = self

    }
    
    private func registerCells() {
        tableView.register(UINib(nibName: SellerHubDashboardTblCell.identifier, bundle: nil), forCellReuseIdentifier: SellerHubDashboardTblCell.identifier)
        tableView.register(UINib(nibName: SellerHubItemsTblCell.identifier, bundle: nil), forCellReuseIdentifier: SellerHubItemsTblCell.identifier)
    }
}

// MARK: - UITableViewDataSource
extension SellerHubVc: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let sectionType = viewModel.sectionType(for: indexPath)
        
        switch sectionType {
        case .dashboard(let dashboardData):
            // Dequeue the dashboard cell

            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SellerHubDashboardTblCell.identifier, for: indexPath) as? SellerHubDashboardTblCell else {
                return UITableViewCell()
            }
            
            cell.configure(with: dashboardData)
            return cell
            
        case .item(let itemData):
            // Dequeue the items cell
           
            guard let cell = tableView.dequeueReusableCell(withIdentifier: SellerHubItemsTblCell.identifier, for: indexPath) as? SellerHubItemsTblCell else {
                return UITableViewCell()
            }
            cell.configure(with: itemData)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SellerHubVc: UITableViewDelegate {
    // Set the cell heights based on which row it is
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            // Dashboard cell
            return 240
        } else {
            // Other three items
            return 100
        }
    }
}

