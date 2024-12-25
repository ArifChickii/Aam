//
//  SellerHubViewModel.swift
//  AAM
//
//  Created by Arif on 25/12/2024.
//

import Foundation


// MARK: - Dashboard Data Model
struct SellerHubDashboardData {
    let activeCount: Int
    let soldCount: Int
    let unsoldCount: Int
}

// MARK: - Items Data Model
struct SellerHubItemData {
    let title: String
    let description: String
    let imageName: String
}

// MARK: - Section Type Enum
enum SellerHubSectionType {
    case dashboard(SellerHubDashboardData)
    case item(SellerHubItemData)
}

// MARK: - View Model
class SellerHubViewModel {
    
    // Data Array (for each row in the table)
    private(set) var sections: [SellerHubSectionType] = []
    
    init() {
        setupData()
    }
    
    private func setupData() {
        // 1. Dashboard row
        let dashboardData = SellerHubDashboardData(activeCount: 0,
                                                   soldCount: 0,
                                                   unsoldCount: 0)
        sections.append(.dashboard(dashboardData))
        
        // 2. Profile
        let profile = SellerHubItemData(title: "Profile",
                                        description: "View your store information",
                                        imageName: "ic_profile")
        sections.append(.item(profile))
        
        // 3. View Listings
        let listings = SellerHubItemData(title: "View Listings",
                                         description: "View and edit your current listings",
                                         imageName: "ic_view_listing")
        sections.append(.item(listings))
        
        // 4. Sold Items
        let soldItems = SellerHubItemData(title: "Sold Items",
                                          description: "Review all your completed sales",
                                          imageName: "ic_sold_items")
        sections.append(.item(soldItems))
    }
    
    // MARK: - Public Methods
    
    func numberOfRows() -> Int {
        return sections.count
    }
    
    func sectionType(for indexPath: IndexPath) -> SellerHubSectionType {
        return sections[indexPath.row]
    }
}
