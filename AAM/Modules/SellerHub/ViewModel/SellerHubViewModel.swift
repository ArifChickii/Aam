//
//  SellerHubViewModel.swift
//  AAM
//
//  Created by Arif on 25/12/2024.
//

import Foundation
import Firebase
import FirebaseAuth

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
    
    /// A reference to your FirebaseService for fetching stats, etc.
    private let firebaseService = FirebaseService()
    
    /// The sections used by the table view in SellerHubVc
    private(set) var sections: [SellerHubSectionType] = []
    
    /// We also keep a reference to current dashboard data
    /// so we can update it after fetching from Firestore
    private var dashboardData: SellerHubDashboardData = SellerHubDashboardData(
        activeCount: 0,
        soldCount:   0,
        unsoldCount: 0
    )
    
    init() {
        setupData()
    }
    
    private func setupData() {
        // 1) Dashboard row (index 0)
        sections.append(.dashboard(dashboardData))
        
        // 2) Profile
        let profile = SellerHubItemData(title: "Profile",
                                        description: "View your store information",
                                        imageName: "ic_profile")
        sections.append(.item(profile))
        
        // 3) View Listings
        let listings = SellerHubItemData(title: "View Listings",
                                         description: "View and edit your current listings",
                                         imageName: "ic_view_listing")
        sections.append(.item(listings))
        
        // 4) Sold Items
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
    
    /// Fetch seller stats from Firestore's "sellerStats/{userId}" doc
    /// and update the first row (dashboard) with real data
    func fetchSellerStats(completion: @escaping () -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            completion()
            return
        }
        
        firebaseService.fetchSellerStats(for: userId) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let statsDoc):
                // Convert Firestore data to integers
                let activeCount = statsDoc["activeCount"] as? Int ?? 0
                let soldCount   = statsDoc["soldCount"]   as? Int ?? 0
                let unsoldCount = statsDoc["unsoldCount"] as? Int ?? 0
                
                // Update local dashboardData
                self.dashboardData = SellerHubDashboardData(
                    activeCount: activeCount,
                    soldCount:   soldCount,
                    unsoldCount: unsoldCount
                )
                
                // Then update our sections[0] to reflect this new data
                self.sections[0] = .dashboard(self.dashboardData)
                
            case .failure(let error):
                // If there's an error, set them to zero or fallback
                print("Failed to fetch seller stats: \(error.localizedDescription)")
                self.dashboardData = SellerHubDashboardData(
                    activeCount: 0,
                    soldCount:   0,
                    unsoldCount: 0
                )
                self.sections[0] = .dashboard(self.dashboardData)
            }
            
            completion()
        }
    }
}


