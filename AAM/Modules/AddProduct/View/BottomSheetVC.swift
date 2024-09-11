//
//  BottomSheetVC.swift
//  AAM
//  Created by Mac on 11/09/2024.
//

import UIKit

class BottomSheetVC: UIViewController, Storyboarded {
    @IBOutlet weak var tbl: UITableView!
    @IBOutlet weak var lblTitle: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
        self.sheetViewController?.handleScrollView(self.tbl)
    }
    func setDelegatesAndDataSources(){
        
        tbl.delegate = self
        tbl.dataSource = self
    }
    
    private func registerCells() {
        
        tbl.register(UINib(nibName: BottomSheetTblCell.identifier, bundle: nil), forCellReuseIdentifier: BottomSheetTblCell.identifier)
        tbl.estimatedRowHeight = 60
        tbl.rowHeight = UITableView.automaticDimension
    }

   

}
extension BottomSheetVC: UITableViewDelegate, UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return self.viewModel.courseList.count
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BottomSheetTblCell.identifier, for: indexPath) as! BottomSheetTblCell
//            cell.configure(obj: viewModel.product)
        return cell
        
        
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("do nothing")
    }
    
}
