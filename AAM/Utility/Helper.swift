//
//  Helper.swift
//  AAM
//
//  Created by Arif ww on 05/08/2024.
//

import Foundation
import UIKit
class Helper{

    
    static var shared = Helper()
    
    static func showAlert(title: String, msg: String, vc: UIViewController, completion: ((Int) -> Void)? = nil){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)

                // add the actions (buttons)
        alert.addAction(UIAlertAction(title: "Continue", style: UIAlertAction.Style.default, handler: { action  in
            
            completion?(1)
            
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { actiiii in
            completion?(0)
        }))

                // show the alert
        vc.present(alert, animated: true, completion: nil)
    }
    
    static func showAlertWithOnlyOk(title: String, msg: String, vc: UIViewController, completion: (() -> Void)? = nil){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)

  
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: { actiiii in
            completion?()
        }))

                // show the alert
        vc.present(alert, animated: true, completion: nil)
    }
    
    func showToast(message : String, vc: UIViewController) {
        
        
        let toastLabel = UILabel(frame: CGRect(x: vc.view.bounds.width/2 - 150, y: vc.view.bounds.height-120, width: 300, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.textAlignment = .center
        toastLabel.numberOfLines = 0
        toastLabel.preferredMaxLayoutWidth = 300
        toastLabel.font = UIFont(name: "Roboto-Regular", size: 12.0)
        toastLabel.text = message
        let size = toastLabel.sizeThatFits(CGSize(width: 300, height: 35))
        if size.height > 35 {
            toastLabel.sizeToFit()
        }
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 7;
        toastLabel.clipsToBounds  =  true
        toastLabel.center = CGPoint(x: vc.view.center.x, y: toastLabel.center.y)
        

        
        vc.view.addSubview(toastLabel)
        UIView.animate(withDuration: 3.0, delay: 1.5, options: .curveEaseIn, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
    
}
