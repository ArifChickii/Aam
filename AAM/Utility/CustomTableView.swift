//
//  CustomTableView.swift
//  AAM
//
//  Created by Arif on 19/09/2024.
//

import Foundation
import UIKit
class CustomTableView: UITableView {

    private let maxHeight = CGFloat(600)
    private let minHeight = CGFloat(100)


    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        if contentSize.height > maxHeight {
            return CGSize(width: contentSize.width, height: maxHeight)
        }
        else if contentSize.height < minHeight {
            return CGSize(width: contentSize.width, height: minHeight)
        }
        else {
            return contentSize
        }
    }

}
