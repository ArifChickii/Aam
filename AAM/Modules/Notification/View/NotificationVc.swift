//
//  NotificationVc.swift
//  AAM
//
//  Created by Arif on 16/12/2024.
//



import UIKit
import UserNotifications

class NotificationVc: UIViewController, Storyboarded {

    // MARK: - Outlets
    @IBOutlet weak var switchAllowNotification: UISwitch!
    
    // MARK: - Properties
    private let viewModel = NotificationViewModel()
    
    /// Keep track of the last known switch state, to revert if user toggles
    private var previousSwitchState: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 1. Check notification status on load
        updateSwitchFromSystemSettings()
        
        // 2. Observe when the app comes back to foreground
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillEnterForeground),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil)
    }
    
    // Alternatively, you can do the re-check in viewWillAppear:
    // override func viewWillAppear(_ animated: Bool) {
    //     super.viewWillAppear(animated)
    //     updateSwitchFromSystemSettings()
    // }
    
    // MARK: - Actions
    
    @IBAction func switchValueChanged(_ sender: UISwitch) {
        // The user toggled the switch. We do NOT update the system setting immediately.
        // Instead, revert the switch to its previous state, show an alert, and if user
        // chooses "Go to Settings," open the Settings app. After returning from Settings,
        // we check again and set the switch properly.
        
        // 1) Revert the switch to the old state right away
        sender.isOn = previousSwitchState
        
        // 2) Show an alert to direct user to settings if they truly want to change
        let title = previousSwitchState
            ? "Turn Off Notifications?"
            : "Turn On Notifications?"
        
        let message = previousSwitchState
            ? "To turn off notifications, please go to Settings and disable them for this app."
            : "To turn on notifications, please allow them in Settings for this app."
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // If user wants to go to Settings, open them
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { [weak self] _ in
            self?.viewModel.openAppSettings()
        }))
        
        // If user cancels, do nothing. The switch remains at previousSwitchState
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(alert, animated: true)
    }
    
    @IBAction func backAction() {
        Router.pop(from: self)
    }
}

// MARK: - Private Helpers
extension NotificationVc {
    
    /// Fetch the real system notification status, then update the switch and previousSwitchState.
    private func updateSwitchFromSystemSettings() {
        viewModel.checkAuthorizationStatus { [weak self] status in
            guard let self = self else { return }
            
            // If authorized or provisional => switch on, else off
            let isAllowed = self.viewModel.isAuthorized(status: status)
            self.switchAllowNotification.isOn = isAllowed
            self.previousSwitchState = isAllowed
        }
    }
    
    /// Called when the app enters the foreground
    @objc private func appWillEnterForeground() {
        // Re-check notification settings
        updateSwitchFromSystemSettings()
    }
}




