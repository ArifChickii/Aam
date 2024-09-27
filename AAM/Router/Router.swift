//
//  Router.swift
//  iOSTask
//
//  Created by Arif ww on 12/07/2024.
//

import Foundation
import UIKit
//import FittedSheets
import BottomSheet

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
    static func MoveToProductDetail(from currentVC: UIViewController, product: ProductInfo) {
        let vc = ProductDetailVC.instantiate(storyBoardName: "Home")
        vc.productDetailObj = product
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    static func MoveToAddProduct(from currentVC: UIViewController) {
        let vc = AddProductVC.instantiate(storyBoardName: "AddProduct")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
//    static func OpenBottomSheet(from currentVC: UIViewController) {
//        let vc = BottomSheetVC.instantiate(storyBoardName: "AddProduct")
//        var options = SheetOptions(
//            shrinkPresentingViewController: false, useInlineMode: false
//        )
//        options.presentingViewCornerRadius = 15
//        let sheetController = SheetViewController(controller: vc, sizes: [.fixed(currentVC.view.frame.height * 0.6),.fullscreen], options: options)
//        
////        sheetController.overlayColor = UIColor.Color99D81C.withAlphaComponent(0.35)
//        currentVC.present(sheetController, animated: true, completion: nil)
//        
//        
//        
//    }

    static func pop(from currentVC: UIViewController) {
        currentVC.navigationController?.popViewController(animated: true)
    }
    

    static func showBottomSheet(from currentVC: UIViewController, bottomeSheetType: Constants.CategoryType, onDataPass: @escaping ([String]) -> Void){
        let bottomSheetVC = BottomSheetVC.instantiate(storyBoardName: "AddProduct")
        bottomSheetVC.bottomSheetType = bottomeSheetType
        
        bottomSheetVC.onDataPass = onDataPass
        
        currentVC.presentBottomSheetInsideNavigationController(
            viewController: bottomSheetVC,
            configuration: Constants.bottomSheetConfiguration,
            canBeDismissed: {
                // return `true` or `false` based on your business logic
                false
            },
            dismissCompletion: {
                // handle bottom sheet dismissal completion
                print("bottom sheet dismisses by arif")
                
            }
        )
                
        
    }

    static func MoveToBottomSheetAsNavigation(from currentVC: UIViewController, bottomeSheetType: Constants.CategoryType, selectedCategor: ProductCategoryForDataRecieving) {
        let vc = BottomSheetVC.instantiate(storyBoardName: "AddProduct")
        vc.selectedCategory = selectedCategor
        vc.bottomSheetType = bottomeSheetType
        currentVC.navigationController?.pushViewController(vc, animated: false)
    }

 
    static func showPriceBottomSheet(from currentVC: UIViewController , onPriceValuePass: @escaping (PriceModelForPassingBack) -> Void){
        let bottomSheetVC = PriceBottomSheetVC.instantiate(storyBoardName: "AddProduct")
        
        bottomSheetVC.onPriceValuePassback = onPriceValuePass
        
        currentVC.presentBottomSheet(
            viewController: bottomSheetVC,
            configuration: Constants.bottomSheetConfiguration,
            canBeDismissed: {
                // return `true` or `false` based on your business logic
                false
            },
            dismissCompletion: {
                // handle bottom sheet dismissal completion
                print("bottom sheet dismisses by arif")
                
            }
        )
                
        
    }
    
    
}
