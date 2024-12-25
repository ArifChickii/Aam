//
//  TabbarVC.swift
//  AAM
//
//  Created by Arif on 09/10/2024.
//

import UIKit

class TabbarVC: UITabBarController, UITabBarControllerDelegate, Storyboarded {
    
    // MARK: - Properties
    private let centerButton = UIButton()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        setupViewControllers()
        setupCenterButton()
        adjustTabBarItems()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // No need for manual positioning when using Auto Layout
    }
    
    // MARK: - Setup Methods
    private func setupViewControllers() {
        // Initialize your existing view controllers
        let firstVC = HomeVC.instantiate(storyBoardName: "Home")
        firstVC.tabBarItem = UITabBarItem(title: "Home",
                                          image: UIImage(named: "ic_home_unselected"),
                                          selectedImage: UIImage(named: "ic_home_selected"))
        
        let secondVC = AddProductVC.instantiate(storyBoardName: "AddProduct")
        secondVC.tabBarItem = UITabBarItem(title: "Profile",
                                           image: UIImage(named: "ic_profile_unselected"),
                                           selectedImage: UIImage(named: "ic_profile_unselected"))
        
        let thirdVC = ProductBagVC.instantiate(storyBoardName: "Payment")
        thirdVC.tabBarItem = UITabBarItem(title: "Favorites",
                                          image: UIImage(named: "ic_cart_unselected"), // Corrected image name
                                          selectedImage: UIImage(named: "ic_cart_selected"))
        
        let fourthVC = SettingsVC.instantiate(storyBoardName: "Settings")
        fourthVC.tabBarItem = UITabBarItem(title: "Settings",
                                           image: UIImage(named: "ic_setting_unselected"),
                                           selectedImage: UIImage(named: "ic_setting_selected"))
        
        // Embed each view controller in a UINavigationController and hide the navigation bar
        let firstNav = UINavigationController(rootViewController: firstVC)
        firstNav.setNavigationBarHidden(true, animated: false) // Hides the navigation bar
        
        let secNav = UINavigationController(rootViewController: secondVC)
        secNav.setNavigationBarHidden(true, animated: false) // Hides the navigation bar
        
        let thirdNav = UINavigationController(rootViewController: thirdVC)
        thirdNav.setNavigationBarHidden(true, animated: false) // Hides the navigation bar
        
        let fourthNav = UINavigationController(rootViewController: fourthVC)
        fourthNav.setNavigationBarHidden(true, animated: false) // Hides the navigation bar
        
        // Placeholder view controller for the center tab
        let placeholderVC = PlaceholderVC()
        placeholderVC.tabBarItem = UITabBarItem(title: nil, image: nil, selectedImage: nil)
        
        // Assign view controllers to the tab bar, placing placeholder in the center
        self.viewControllers = [firstNav, secNav, placeholderVC, thirdNav, fourthNav]
    }
    
    private func setupCenterButton() {
        // Set the button's image
        if let buttonImage = UIImage(named: "ic_add_tabbar") {
            centerButton.setImage(buttonImage, for: .normal)
        } else {
            // Fallback to a default system image if your custom icon isn't found
            centerButton.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        }
        
        // Configure button appearance
        centerButton.backgroundColor = .white
        centerButton.layer.cornerRadius = 30
        centerButton.layer.shadowColor = UIColor.black.cgColor
        centerButton.layer.shadowOpacity = 0.3
        centerButton.layer.shadowOffset = CGSize(width: 0, height: 5)
        centerButton.layer.shadowRadius = 5
        
        // Add action
        centerButton.addTarget(self, action: #selector(centerButtonTapped), for: .touchUpInside)
        
        // Add to the view hierarchy
        centerButton.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(centerButton)
        
        // Accessibility
        centerButton.accessibilityLabel = "Add Product"
        centerButton.accessibilityHint = "Opens the add product screen"
        
        // Constraints
        NSLayoutConstraint.activate([
            centerButton.centerXAnchor.constraint(equalTo: tabBar.centerXAnchor),
            centerButton.centerYAnchor.constraint(equalTo: tabBar.topAnchor),
            centerButton.widthAnchor.constraint(equalToConstant: 60),
            centerButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Ensure the button is above other views
        self.view.bringSubviewToFront(centerButton)
    }
    
    private func adjustTabBarItems() {
        guard let items = tabBar.items else { return }
        
        // Iterate through all tab bar items except the placeholder
        for (index, item) in items.enumerated() {
            if viewControllers?[index] is PlaceholderVC {
                // Skip the placeholder
                continue
            }
            // Adjust image and title insets if necessary
            item.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
            item.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: 3)
        }
    }
    
    // MARK: - Action Methods
    @objc private func centerButtonTapped() {
        let centerVC = AddProductVC.instantiate(storyBoardName: "AddProduct")
        centerVC.modalPresentationStyle = .fullScreen
        self.present(centerVC, animated: true, completion: nil)
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is PlaceholderVC {
            // Prevent selection of the placeholder tab
            return false
        }
        return true
    }
}

