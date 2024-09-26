//
//  UIColor.swift
//  AAM
//
//  Created by Arif ww on 01/08/2024.
//

import Foundation
import UIKit

extension UIColor {
    // Convenience initializer for UIColor using hex value
    convenience init(hex: String) {
        let hexString = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        // Remove the "#" prefix if it exists
        let cleanHexString = hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString
        
        // Ensure the string is 6 characters long
        guard cleanHexString.count == 6 else {
            self.init(white: 0.0, alpha: 1.0)
            return
        }
        
        var rgbValue: UInt64 = 0
        Scanner(string: cleanHexString).scanHexInt64(&rgbValue)
        
        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
    
    // Static method for convenience
    static func fromHex(_ hex: String) -> UIColor {
        return UIColor(hex: hex)
    }
}
