//
//  ProductBagTblCell.swift
//  AAM
//
//  Created by Arif on 04/11/2024.
//

import UIKit
import SDWebImage

/// Delegate protocol to handle actions from the cell.
protocol ProductBagTblCellDelegate: AnyObject {
    func incrementButtonTapped(at indexPath: IndexPath)
    func decrementButtonTapped(at indexPath: IndexPath)
    func deleteButtonTapped(at indexPath: IndexPath)
}

class ProductBagTblCell: UITableViewCell {
    static let identifier = "ProductBagTblCell"
    
    @IBOutlet weak var imgProduct: UIImageView!
    @IBOutlet weak var lblProductTitle: UILabel!
    @IBOutlet weak var lblColorAndSize: UILabel!
    @IBOutlet weak var lblCounter: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var btnIncrement: UIButton!
    @IBOutlet weak var btnDecrement: UIButton!
    @IBOutlet weak var btnDelete: UIButton!
    
    weak var delegate: ProductBagTblCellDelegate?
    var indexPath: IndexPath?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Connect buttons to actions
        btnIncrement.addTarget(self, action: #selector(incrementButtonTapped), for: .touchUpInside)
        btnDecrement.addTarget(self, action: #selector(decrementButtonTapped), for: .touchUpInside)
        btnDelete.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }

    @objc private func incrementButtonTapped() {
        if let indexPath = indexPath {
            delegate?.incrementButtonTapped(at: indexPath)
        }
    }
    
    @objc private func decrementButtonTapped() {
        if let indexPath = indexPath {
            delegate?.decrementButtonTapped(at: indexPath)
        }
    }
    
    @objc private func deleteButtonTapped() {
        if let indexPath = indexPath {
            delegate?.deleteButtonTapped(at: indexPath)
        }
    }
    
    /// Configures the cell with a `BagProduct`.
    /// - Parameter bagProduct: The product to display.
    func configure(with bagProduct: BagProduct) {
        let product = bagProduct.product
        lblProductTitle.text = product.title ?? ""
        lblCounter.text = "\(bagProduct.count)"
        lblPrice.text = product.price ?? ""
        
        // Assuming colors and sizes are arrays
        lblColorAndSize.text = "Color: \(product.colors?.first ?? "") Size: \(product.sizes?.first ?? "")"
        
        // Load image
        if let imageUrlString = product.images?.first, let imageUrl = URL(string: imageUrlString) {
            imgProduct.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            imgProduct.image = UIImage(named: "placeholder")
        }
    }
}

