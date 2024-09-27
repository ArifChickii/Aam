//
//  PriceBottomSheetVC.swift
//  AAM
//
//  Created by Arif on 27/09/2024.
//

import UIKit
struct PriceModelForPassingBack {
    var price: String
    var cutPrice: String
}

class PriceBottomSheetVC: UIViewController, Storyboarded {
    
    @IBOutlet weak var txtPrice: UITextField!
    @IBOutlet weak var txtCutPrice: UITextField!
    var onPriceValuePassback: ((PriceModelForPassingBack) -> Void)?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // Ensure the layout is updated
        self.view.layoutIfNeeded()
        
        // Calculate the dynamic size based on the main view of the view controller
        let targetSize = self.view.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        
        // Set the preferred content size for the bottom sheet
        self.preferredContentSize = CGSize(width: self.view.frame.width, height: targetSize.height)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationController = self.navigationController{
            navigationController.navigationBar.isHidden = true
        }
        
        
       
    }
    

    @IBAction func saveAction(){
        if (txtPrice.text == "") || txtCutPrice.text == ""{
            Helper.shared.showToast(message: "please enter prices", vc: self)
        }else{
            let price = self.txtPrice.text ?? ""
            let cutPrice = self.txtCutPrice.text ?? ""
            onPriceValuePassback?(PriceModelForPassingBack(price: price, cutPrice: cutPrice))
            self.dismiss(animated: true)
        }
    }

}
