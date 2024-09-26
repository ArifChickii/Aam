//
//  onBoardingViewModel.swift
//  AAM
//
//  Created by Arif ww on 01/08/2024.


import Foundation
import UIKit

protocol OnBoardingViewModelDelegate: AnyObject {
    func moveToStep(step: Int)
}
class onBoardingViewModel{
    
    weak var delegate: OnBoardingViewModelDelegate?
    var currentStep : Int = 0{
        didSet{
            delegate?.moveToStep(step: currentStep)
        }
    }
    
    private(set) lazy var orderedViewControllers: [UIViewController] = {
        return [self.newOnBoardingController("1"),
                self.newOnBoardingController("2"),
                self.newOnBoardingController("3")
        ]
    }()
    
    private func newOnBoardingController(_ name: String) -> UIViewController {
        let vc =  UIStoryboard(name: "Onboarding", bundle: nil).instantiateViewController(withIdentifier: "onBoardingPage\(name)")
        return vc
        
    }
    

}
