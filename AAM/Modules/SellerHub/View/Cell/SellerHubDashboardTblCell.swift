//
//  SellerHubDashboardTblCell.swift
//  AAM
//
//  Created by Arif on 25/12/2024.
//

import UIKit

class SellerHubDashboardTblCell: UITableViewCell {
    static let identifier = "SellerHubDashboardTblCell"
    // MARK: - Outlets
    @IBOutlet weak var lblActiveTitle: UILabel!
    @IBOutlet weak var lblActiveCount: UILabel!
    
    @IBOutlet weak var lblSoldTitle: UILabel!
    @IBOutlet weak var lblSoldCount: UILabel!
    
    @IBOutlet weak var lblUnsoldTitle: UILabel!
    @IBOutlet weak var lblUnsoldCount: UILabel!
    
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblDesc: UILabel!
    
    // If you don’t have these outlets in storyboard yet,
    // create them and connect them to your cell's layout.

    override func awakeFromNib() {
        super.awakeFromNib()
        setupFonts()
    }
    
    func configure(with dashboardData: SellerHubDashboardData) {
        lblActiveCount.text = "\(dashboardData.activeCount)"
        lblSoldCount.text = "\(dashboardData.soldCount)"
        lblUnsoldCount.text = "\(dashboardData.unsoldCount)"
        
        // Titles
        lblActiveTitle.text = "Active"
        lblSoldTitle.text = "Sold"
        lblUnsoldTitle.text = "Unsold"
    }
    
    private func setupFonts() {
        
        lblTitle.font = UIFont(name: "Jost SemiBold", size: 16)
        lblDesc.font = UIFont(name: "Jost Medium", size: 14)
        
        // Count Labels
        lblActiveCount.font = UIFont(name: "Jost SemiBold", size: 16)
        lblSoldCount.font   = UIFont(name: "Jost SemiBold", size: 16)
        lblUnsoldCount.font = UIFont(name: "Jost SemiBold", size: 16)
        
        
        // Titles (Active, Sold, Unsold)
        lblActiveTitle.font = UIFont(name: "Jost Regular", size: 14)
        lblSoldTitle.font   = UIFont(name: "Jost Regular", size: 14)
        lblUnsoldTitle.font = UIFont(name: "Jost Regular", size: 14)
        
        
    }
}

