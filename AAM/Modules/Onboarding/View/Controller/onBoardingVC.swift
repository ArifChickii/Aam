//
//  onBoardingVC.swift
//  AAM
//
//  Created by Arif ww on 01/08/2024.
//

import UIKit

class onBoardingVC: UIViewController, OnBoardingViewModelDelegate {
    
    @IBOutlet weak var btnNext: UIButton!
    var pageViewController: UIPageViewController!
    @IBOutlet var indicatorViewsArray: [UIView]!
    @IBOutlet var indicatorViewWidthConsArray: [NSLayoutConstraint]!
    private let viewModel = onBoardingViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        viewModel.delegate = self
        viewModel.currentStep = 0
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Router.MoveToHome(from: self)
    }
    
    
    
    
    @IBAction func btnNext_Pressed(_ sender: UIButton) {
        
//        UserDefaults.standard.set(true, forKey: "isOnboaringShown")
        Router.showAuthenticationVC(from: self)
      
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        
        if let vc = segue.destination as? UIPageViewController {
            vc.delegate = self
            vc.dataSource = self
            self.pageViewController = vc
            
            if let firstViewController = viewModel.orderedViewControllers.first {
                vc.setViewControllers([firstViewController],
                                      direction: .forward,
                                      animated: true,
                                      completion: nil)
            }
            
        }
    }

    
    @objc func onDidReceiveData(_ notification:Notification) {
        moveToStep(step: viewModel.currentStep + 1)
        pageViewController?.setViewControllers([viewModel.orderedViewControllers[viewModel.currentStep + 1]], direction: .forward, animated: true, completion: { [self] (sts) in
            viewModel.currentStep = self.viewModel.currentStep + 1
            
        })
    }

    func moveToStep(step:Int) {
        for i in 0 ..< self.indicatorViewsArray.count{
            let views = self.indicatorViewsArray[i]
            let widthConstant = self.indicatorViewWidthConsArray[i]
            widthConstant.constant = 9
            views.layer.cornerRadius = 4.5
            views.backgroundColor = ColorConstants.indicatorColor
            if i == step{
                UIView.animate(withDuration: 0.8) {
                    widthConstant.constant = 24
                    views.layer.cornerRadius = 4.5
                    views.backgroundColor = ColorConstants.mainThemeColor
                    views.layoutIfNeeded()
                }
                
            }
            
        }
        
    }

}



extension onBoardingVC : UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        guard completed else { return }
        let vc = pageViewController.viewControllers!.first!
        
        guard let viewControllerIndex = viewModel.orderedViewControllers.firstIndex(of: vc) else {
            return
        }
        viewModel.currentStep = viewControllerIndex
        //moveToStep(step:viewControllerIndex)
       // self.moveToStep(step: crrentStep)
    }
    
}


extension onBoardingVC : UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        guard let viewControllerIndex = viewModel.orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewModel.orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return viewModel.orderedViewControllers[previousIndex]
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = viewModel.orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = viewModel.orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return viewModel.orderedViewControllers[nextIndex]
        
    }
    
    
    
    
  
}
