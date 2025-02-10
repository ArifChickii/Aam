//
//  NotificationListVc.swift
//  AAM
//
//  Created by Arif on 10/02/2025.
//




struct NotificationModel: Codable {
     var id: String?
    var title: String?
    var body: String?
    var timestamp: Date?
    var read: Bool?
}

import UIKit
import FirebaseAuth
import FirebaseFirestore

class NotificationListVc: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var notifications: [NotificationModel] = []
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate   = self
        
        fetchNotifications()
    }
    
    deinit {
        // If using a listener, remove it
        listener?.remove()
    }
    
    private func fetchNotifications() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Real-time listener to "notifications" sub-collection
        listener = db.collection("users")
            .document(userId)
            .collection("notifications")
            .order(by: "timestamp", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    print("Error fetching notifications: \(error.localizedDescription)")
                    return
                }
                
                var tempList: [NotificationModel] = []
                for doc in snapshot?.documents ?? [] {
                    do {
                        let notif = try doc.data(as: NotificationModel.self)
                        tempList.append(notif)
                    } catch {
                        print("Error decoding notification: \(error.localizedDescription)")
                    }
                }
                self.notifications = tempList
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
    }
    
    
    @IBAction func backBtnAction() {
        Router.pop(from: self)
    }
}

extension NotificationListVc: UITableViewDataSource, UITableViewDelegate {
    // 1) Number of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }
    
    // 2) Cell for row
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Make sure your storyboard cell has identifier = "NotificationCell"
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "NotificationTblCell",
            for: indexPath
        ) as? NotificationTblCell else {
            return UITableViewCell()
        }
        
        let notif = notifications[indexPath.row]
        // If you have a custom cell, cast it, otherwise just set textLabel
        cell.textLabel?.text = notif.body
        
        // Optionally format date or show `title` as well
        return cell
    }
    
    // 3) (Optional) didSelectRow -> mark as read or open detail
    func tableView(_ tableView: UITableView,
                   didSelectRowAt indexPath: IndexPath) {
        // If you want to mark as read in Firestore, do that here
    }
}
