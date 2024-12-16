//
//  SettingsVC.swift
//  AAM
//
//  Created by Arif on 15/12/2024.
//

import UIKit

class SettingsVC: UIViewController, Storyboarded {
    
    // MARK: - Outlets
    
    @IBOutlet weak var settingsTableView: UITableView!
    
    // MARK: - Properties
    
    private let viewModel = SettingsViewModel()
    
    // MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup delegates and data sources
        setupDelegatesAndDataSources()
        registerCells()
        
        // Load settings
        loadSettings()
    }
    
    // MARK: - Setup Methods
    
    private func setupDelegatesAndDataSources() {
        settingsTableView.delegate = self
        settingsTableView.dataSource = self
        settingsTableView.tableFooterView = UIView() // Removes empty cell separators
    }
    
    private func registerCells() {
        settingsTableView.register(UINib(nibName: SettingLabelTblCell.identifier, bundle: nil), forCellReuseIdentifier: SettingLabelTblCell.identifier)
    }
    
    private func loadSettings() {
        // Since settings are static, simply reload the table view
        settingsTableView.reloadData()
    }
    
    // MARK: - Helper Methods
    
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error",
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true)
    }
}
 
// MARK: - UITableViewDelegate & UITableViewDataSource

extension SettingsVC: UITableViewDelegate, UITableViewDataSource {
    
    // Number of rows based on settings titles
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return viewModel.numberOfSettings()
    }
    
    // Configure each cell with the corresponding setting title
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        guard let cell = tableView.dequeueReusableCell(withIdentifier: SettingLabelTblCell.identifier, for: indexPath) as? SettingLabelTblCell else {
            return UITableViewCell()
        }
        
        let title = viewModel.settingTitle(at: indexPath.row)
        cell.lblTitle.text = title
        
        // Disable cell selection highlighting
        cell.selectionStyle = .none
        
        return cell
    }
    
    // Handle cell selection with print statements
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let title = viewModel.settingTitle(at: indexPath.row)
        
        // Print the selected title
        print("Selected: \(title)")
        
        // Handle selection based on the title
        switch title {
        case "Profile":
            print("Navigate to Profile screen")
            // Example: Navigate to ProfileVC
            // Router.MoveToProfile(from: self)
            
        case "Shipping":
            print("Navigate to Shipping screen")
            // Example: Navigate to ShippingVC
            // Router.MoveToShipping(from: self)
            
        case "Notification":
            print("Navigate to Notification settings")
            // Example: Navigate to NotificationSettingsVC
            // Router.MoveToNotificationSettings(from: self)
            
        case "Logout":
            print("Handle Logout")
            // Example: Perform logout operations
            // handleLogout()
            
        default:
            break
        }
    }
    
    // Optional: Set row height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50 // Adjust based on your design
    }
}

