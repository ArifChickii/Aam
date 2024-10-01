//
//  Storyboard.swift
//  iOSTask
//
//  Created by Arif ww on 12/07/2024.
//


import Foundation
import UIKit

extension UIView {
    
    func applyWhiteBg() {
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "white-view-bg")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    func applyBottomBarBg() {
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "bottom-navigation-bg.png")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    func appleConnectBackground() {
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "connect-view-bg")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
    func applyBioBoxBg() {
        UIGraphicsBeginImageContext(self.frame.size)
        UIImage(named: "bio-box")?.draw(in: self.bounds)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        self.backgroundColor = UIColor(patternImage: image)
    }
    
}

//MARK:- IBInspectable
extension UIView {
    @IBInspectable var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }

    @IBInspectable var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }

    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.masksToBounds = false
            layer.shadowRadius = newValue
        }
    }

    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.masksToBounds = false
            layer.shadowOpacity = newValue
        }
    }

    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.masksToBounds = false
            layer.shadowOffset = newValue
        }
    }

    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}


extension UIView {
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: self.bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        self.layer.mask = maskLayer
    }
    
    
    func roundCornersContinuously(corners: UIRectCorner, radius: CGFloat) {
            self.layoutIfNeeded() 
            self.roundCorners(corners: corners, radius: radius)
        }
}


extension UIView {

    
    func addRemoveAbleBorder(color: UIColor, width: CGFloat = 1.0) {
            let borderLayer = CALayer()
            borderLayer.name = "customBorderLayer" // Add a name to identify this layer
            borderLayer.frame = self.bounds
            borderLayer.borderWidth = width
            borderLayer.borderColor = color.cgColor
        
        borderLayer.cornerRadius = self.layer.cornerRadius
        borderLayer.masksToBounds = true
            self.layer.addSublayer(borderLayer)
    }
    func removeBorders() {
            if let sublayers = self.layer.sublayers {
                for layer in sublayers where layer.name == "customBorderLayer" {
                    layer.removeFromSuperlayer() // Remove only the custom border layer
                }
            }
        }



    
}
