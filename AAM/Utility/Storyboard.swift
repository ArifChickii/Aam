//
//  Storyboard.swift
//  iOSTask
//
//  Created by Arif ww on 12/07/2024.
//

import Foundation
import UIKit

protocol Storyboarded {
    static func instantiate(storyBoardName:String) -> Self
}

extension Storyboarded where Self: UIViewController {
    static func instantiate(storyBoardName:String = "Home") -> Self {
        
        let fullName = NSStringFromClass(self)
        let className = fullName.components(separatedBy: ".")[1]
        let storyboard = UIStoryboard(name: storyBoardName, bundle: Bundle.main)
        return storyboard.instantiateViewController(withIdentifier: className) as! Self
    }
}
