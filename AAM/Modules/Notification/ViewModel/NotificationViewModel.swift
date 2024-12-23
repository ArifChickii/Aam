//
//  NotificationViewModel.swift
//  AAM
//
//  Created by Arif on 23/12/2024.
//


import Foundation
import UserNotifications
import UIKit

final class NotificationViewModel {
    
    /// Checks the current notification authorization status.
    /// - Parameter completion: Returns the current `UNAuthorizationStatus`.
    func checkAuthorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus)
            }
        }
    }
    
    /// Returns `true` if notifications are fully authorized (.authorized or .provisional), otherwise `false`.
    func isAuthorized(status: UNAuthorizationStatus) -> Bool {
        return status == .authorized || status == .provisional
    }
    
    /// Opens the app-specific notification settings in iOS Settings.
    func openAppSettings() {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsURL) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

