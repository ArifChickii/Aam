//
//  SettingsViewModel.swift
//  AAM
//
//  Created by Arif on 16/12/2024.
//

import Foundation

class SettingsViewModel {
    
    // MARK: - Properties
    
    private let settingsTitles: [String] = ["Profile", "Shipping", "Notification", "Logout"]
    
    // MARK: - Methods
    
    func numberOfSettings() -> Int {
        return settingsTitles.count
    }
    
    func settingTitle(at index: Int) -> String {
        guard index >= 0 && index < settingsTitles.count else {
            return ""
        }
        return settingsTitles[index]
    }
}

