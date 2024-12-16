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
    
    static func MoveToLogin(from currentVC: UIViewController) {
        
        
         let loginVC = AuthenticationVC.instantiate(storyBoardName: "Authentication")
        
        // Option 1: Reset Root View Controller to LoginVC
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController = loginVC
            window.makeKeyAndVisible()
        }
        

    }
    
    
    static func showAuthenticationVC(from currentVC: UIViewController) {
        let vc = AuthenticationVC.instantiate(storyBoardName: "Authentication")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func MoveToHome(from currentVC: UIViewController) {
        let vc = HomeVC.instantiate(storyBoardName: "Home")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func setHomeAsRootVC() {
        
        if let vc = TabbarVC.instantiate(storyBoardName: "Tabbar") as? TabbarVC {
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
    
    static func MoveToProductsBagVC(from currentVC: UIViewController) {
        let vc = ProductBagVC.instantiate(storyBoardName: "Payment")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    static func MoveToCheckOutFormVC(from currentVC: UIViewController, addressToEdit: ShippingAddress?) {
            let vc = CheckoutFormVC.instantiate(storyBoardName: "Payment")
            vc.addressToEdit = addressToEdit
            currentVC.navigationController?.pushViewController(vc, animated: true)
        }
    static func MoveToAddProduct(from currentVC: UIViewController) {
        let vc = AddProductVC.instantiate(storyBoardName: "AddProduct")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    static func MoveToSelectShippingAddress(from currentVC: UIViewController) {
        let vc = SelectShippingAddressVC.instantiate(storyBoardName: "Payment")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    static func MoveToSelectPaymentMethod(from currentVC: UIViewController) {
        let vc = PaymentMethodVC.instantiate(storyBoardName: "Payment")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    static func MoveToAddCardInfo(from currentVC: UIViewController) {
        let vc = AddCardInfoVC.instantiate(storyBoardName: "Payment")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func MoveToNotificationVC(from currentVC: UIViewController) {
        let vc = NotificationVc.instantiate(storyBoardName: "Notification")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
//    static func MoveToOrderInfo(from currentVC: UIViewController) {
//        let vc = OrderInfoVC.instantiate(storyBoardName: "Payment")
//        currentVC.navigationController?.pushViewController(vc, animated: true)
//    }
    
    static func MoveToOrderInfo(from currentVC: UIViewController, bagProducts: [BagProduct], selectedAddress: ShippingAddress) {
        let orderInfoVC = OrderInfoVC.instantiate(storyBoardName: "Payment")
        orderInfoVC.viewModel = OrderInfoViewModel(bagProducts: bagProducts, selectedAddress: selectedAddress)
        currentVC.navigationController?.pushViewController(orderInfoVC, animated: true)
    }
    
    static func showSuccessDialog(from currentVC: UIViewController) {
        let vc = DialogeVC.instantiate(storyBoardName: "Payment")
        vc.modalPresentationStyle = .overFullScreen
        currentVC.present(vc, animated: false, completion: nil)
        
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
    
    static func dismiss(from currentVC: UIViewController) {
        currentVC.dismiss(animated: true)
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
