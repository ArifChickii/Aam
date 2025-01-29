import UIKit
import SDWebImage

class ProductRatingTblCell: UITableViewCell {
    
    static let identifier = "ProductRatingTblCell"
    
    @IBOutlet weak var lblOwnerName: UILabel!
    @IBOutlet weak var imgOwner: UIImageView!
    @IBOutlet weak var lblOwnerFirstLetter: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }
    
    // If you still want rating, you can add a rating label here, or handle it.
    // We'll skip rating logic for clarity, focusing on the owner info.
    
    func configureOwnerInfo(product: ProductInfo) {
        guard let owner = product.owner_infor else {
            // If there's no owner, you might hide the cell or show "No owner info"
            lblOwnerName.text = "No owner info"
            imgOwner.isHidden = true
            lblOwnerFirstLetter.isHidden = true
            return
        }
        
        // Show the owner name
        if let ownerName = owner.userName{
            lblOwnerName.text = ownerName
        }else{
            lblOwnerName.text =  ""
        }
        if let imgUrl = owner.profileImageUrl, imgUrl != ""{
            // We have a profile URL
            imgOwner.isHidden = false
            lblOwnerFirstLetter.isHidden = true
            
            if let url = URL(string: owner.profileImageUrl ?? "") {
                imgOwner.sd_setImage(with: url,
                                     placeholderImage: UIImage(named: "Placeholder"),
                                     options: [.scaleDownLargeImages],
                                     context: nil)
            } else {
                // If URL is invalid
                imgOwner.image = UIImage(named: "Placeholder")
            }
            
        }else{
            imgOwner.isHidden = true
            // Show first letter label
            lblOwnerFirstLetter.isHidden = false
            if let firstLetter = owner.userName?.first {
                lblOwnerFirstLetter.text = String(firstLetter).uppercased()
            } else {
                lblOwnerFirstLetter.text = "U" // fallback
            }
        }
        
        
        
    }
}

