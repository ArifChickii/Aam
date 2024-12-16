//
//  NotificationVc.swift
//  AAM
//
//  Created by Arif on 16/12/2024.
//

import UIKit

class NotificationVc: UIViewController, Storyboarded {
    
    @IBOutlet weak var switchAllowNotification: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    @IBAction func backAction(){
        Router.pop(from: self)
    }

}
