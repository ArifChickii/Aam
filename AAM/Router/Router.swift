//
//  Router.swift
//  iOSTask
//
//  Created by Arif ww on 12/07/2024.
//

import Foundation
import UIKit

class Router {
    
    static func showDashboard(from currentVC: UIViewController) {
        let vc = DashboardVC.instantiate(storyBoardName: "Dashboard")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func showCourseDetail(from currentVC: UIViewController, courseObj: CourseModel) {
        let vc = CourseDetailVC.instantiate(storyBoardName: "CourseDetail")
        vc.courseObj = courseObj
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func showSampleVC(from currentVC: UIViewController) {
        let vc = SampleVC.instantiate(storyBoardName: "Sample")
        currentVC.navigationController?.pushViewController(vc, animated: true)
    }
    
    static func pop(from currentVC: UIViewController) {
        currentVC.navigationController?.popViewController(animated: true)
    }
    

    

    

 
}
