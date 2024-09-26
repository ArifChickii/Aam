//
//  Constants.swift
//  AAM
//
//  Created by Arif ww on 01/08/2024.
//

import Foundation
import BottomSheet
import UIKit
class Constants{
    static let shared = Constants()
    
    var linkingAlertTitle = "Email Already in Use"
    var googleLinkingDesc = "There is already a Google account with this email address. Continue to login with Google."
    var appleLinkingDesc = "There is already an Apple account with this email address. Continue to login with Apple."
    var colorsList = [DropDown]()
    var fabricList = [DropDown]()
    var sizesList = [DropDown]()
    var categoriesList = [ProductCategory]()
    static let bottomSheetConfiguration = BottomSheetConfiguration(
        cornerRadius: 20,
        pullBarConfiguration: .visible(.init(height: 12)),
        
        shadowConfiguration: .init(backgroundColor: UIColor.black.withAlphaComponent(0.6))
    )
    
    
    enum CategoryType: String {
        case category = "Category"
        case subCategory = "Subcategory"
        case size = "Size"
        case color = "Color"
        case price = "Price"
        case fabric = "fabric"
        
    }
    
}

struct UserDefaultsKeys{
    static let isUserLogin = "isUserLogin"
}


extension Notification.Name {
    static let didDismissBottomSheet = Notification.Name("didDismissBottomSheet")
}
