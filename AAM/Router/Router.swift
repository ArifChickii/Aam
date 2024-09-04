//
//  Router.swift
//  iOSTask
//
//  Created by Arif ww on 12/07/2024.
//

import Foundation
import UIKit

class Router {
    
   
    
    static func showAuthenticationVC(from currentVC: UIViewController) {
        let vc = AuthenticationVC.instantiate(storyBoardName: "Authentication")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func MoveToHome(from currentVC: UIViewController) {
        let vc = HomeVC.instantiate(storyBoardName: "Home")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func setHomeAsRootVC() {
        
        if let vc = HomeVC.instantiate(storyBoardName: "Home") as? HomeVC {
            // Replace the root view controller
            guard let window = UIApplication.shared.windows.first else { return }
            let navigationController = UINavigationController(rootViewController: vc)
            navigationController.setNavigationBarHidden(true, animated: false) // Hide the navigation bar
            
            window.rootViewController = navigationController
            window.makeKeyAndVisible()
        }
                
        
    }
    static func MoveToProductDetail(from currentVC: UIViewController, product: Product) {
        let vc = ProductDetailVC.instantiate(storyBoardName: "Home")
        vc.productDetailObj = product
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    static func MoveToAddProduct(from currentVC: UIViewController) {
        let vc = AddProductVC.instantiate(storyBoardName: "AddProduct")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }

    static func pop(from currentVC: UIViewController) {
        currentVC.navigationController?.popViewController(animated: true)
    }
    

    

    

 
}
