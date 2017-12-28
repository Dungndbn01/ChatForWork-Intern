//
//  MyTaskController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/26/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class RequestedTaskController: UITableViewController {
    var messageTasks = [Message]()
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observerUserTasks()
        self.tableView.isScrollEnabled = true
        self.tableView.backgroundColor = .white
        self.tableView.register(MyTaskCell.self, forCellReuseIdentifier: cellId)
        
    }
    
    func observerUserTasks() {
        if let uid = Auth.auth().currentUser?.uid {
            let taskRef = Database.database().reference().child("requested-task").child(uid)
            taskRef.observe(.childAdded, with: {
                (DataSnapshot) in
                let messageId = DataSnapshot.key
                let messageRef1 = Database.database().reference().child("message").child(messageId).child("infoDict")
                messageRef1.observeSingleEvent(of: .value, with: {
                    (DataSnapshot1) in
                    let dictionary1 = (DataSnapshot1.value as? [String : AnyObject])!
                    let messageRef2 = Database.database().reference().child("message").child(messageId).child("urlDict")
                    messageRef2.observeSingleEvent(of: .value, with: {
                        (DataSnapshot2) in
                        let dictionary2 = (DataSnapshot2.value as? [String : String])!
                        let messageRef3 = Database.database().reference().child("message").child(messageId).child("nameDict")
                        messageRef3.observeSingleEvent(of: .value, with: {
                            (DataSnapshot3) in
                            let dictionary3 = (DataSnapshot3.value as? [String : String])!
                            let message = Message(dictionary1: dictionary1 as [String : AnyObject], dictionary2: dictionary2 as [String : String], dictionary3: dictionary3 as [String : String])
                            DispatchQueue.main.async {
                                self.messageTasks.append(message)
                                self.tableView.reloadData()
                            }
                        })
                    })
                })
            })
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageTasks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MyTaskCell
        cell.task = messageTasks[indexPath.row]
        cell.profileImageView.isHidden = false
        cell.squareView.isHidden = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskDetail = TaskDetailController()
        taskDetail.task = messageTasks[indexPath.row]
        self.navigationController?.pushViewController(taskDetail, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

