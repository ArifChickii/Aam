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
    

    static func pop(from currentVC: UIViewController) {
        currentVC.navigationController?.popViewController(animated: true)
    }
    

    

    

 
}
