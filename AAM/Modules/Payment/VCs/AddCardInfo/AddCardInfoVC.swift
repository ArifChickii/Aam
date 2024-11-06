//
//  AddCardInfoVC.swift
//  AAM
//
//  Created by Arif on 05/11/2024.
//

import UIKit


class AddCardInfoVC: UIViewController, Storyboarded {
    var viewModel = AddCardInfoViewModel()
    @IBOutlet weak var formTblView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setDelegatesAndDataSources()
        registerCells()
        
        formTblView.estimatedRowHeight = 100
        formTblView.rowHeight = UITableView.automaticDimension
    }
    private func registerCells() {
        formTblView.register(UINib(nibName: FormTblCell.identifier, bundle: nil), forCellReuseIdentifier: FormTblCell.identifier)
        
    }
    
    private func setDelegatesAndDataSources() {
        formTblView.delegate = self
        formTblView.dataSource = self
        
    }
    @IBAction func backAction(){
        Router.pop(from: self)
    }
    @IBAction func Continue(){
        Router.MoveToOrderInfo(from: self)
    }


}
extension AddCardInfoVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.viewModel.formFields.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = self.viewModel.formFields[indexPath.row]
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FormTblCell.identifier, for: indexPath) as? FormTblCell else {
            return UITableViewCell()
        }
        
        cell.configure(obj: item)
        return cell


    }
    
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    
}
