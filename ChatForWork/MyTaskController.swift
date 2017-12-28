//
//  MyTaskController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/26/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class MyTaskController: UITableViewController {
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
            let taskRef = Database.database().reference().child("user-task").child(uid)
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
        cell.squareView.isHidden = false
        cell.profileImageView.isHidden = true
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let taskDetail = TaskDetailController()
        taskDetail.task = messageTasks[indexPath.row]
        self.navigationController?.pushViewController(taskDetail, animated: true)
    }

}

class MyTaskCell: UITableViewCell {
    var profileImageView = UIImageView()
    var squareView = UIView()
    var taskTextView = UITextView()
    var dueDateView = UILabel()
    
    var task: Message? {
        didSet {
            setupViews()
        }
    }
    
    func setupViews() {
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.loadImageUsingCacheWithUrlString(urlString: MyObject.instance().myProfileImageUrl!)
        profileImageView.isHidden = true
        
        squareView.layer.cornerRadius = 5
        squareView.layer.masksToBounds = true
        squareView.layer.borderColor = UIColor.gray.cgColor
        squareView.layer.borderWidth = 1
        squareView.isHidden = true
        
        taskTextView.text = task?.text
        taskTextView.font = UIFont.systemFont(ofSize: 16)
        taskTextView.isEditable = false
        taskTextView.isSelectable = false
        taskTextView.isUserInteractionEnabled = false
        taskTextView.backgroundColor = .clear
        dueDateView.text = "Due Date: \(task?.dueDate ?? "")"
        dueDateView.textColor = .red
        
        contentView.addSubview(profileImageView)
        contentView.addSubview(squareView)
        contentView.addSubview(taskTextView)
        contentView.addSubview(dueDateView)
        
        profileImageView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        squareView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        taskTextView.anchor(contentView.topAnchor, left: squareView.rightAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 20, leftConstant: 12, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 50)
        dueDateView.anchor(nil, left: squareView.rightAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 12, rightConstant: 12, widthConstant: 0, heightConstant: 18)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
