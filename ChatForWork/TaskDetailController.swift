//
//  TaskDetailController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/26/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class TaskDetailController: UITableViewController {
    var task: Message?
    let cellId = "cellId"
    let headerId = "headerId"
    let leftLogoLabelArr = ["Due Date", "Chat", "Assignee"]
    let leftLabelArr = ["Jump to Assignment", "Edit", "Delete"]
    var rightLabelArr = [String]()
    let leftLogoNameArr = ["CalendarICO", "message_icon-1", "account_icon"]

    override func viewDidLoad() {
        super.viewDidLoad()
        rightLabelArr = [(task?.dueDate)!, (task?.taskReceiver)!, (task?.taskRequestor)!]
        self.navigationItem.title = "Task Detail"
        
        self.tableView = UITableView(frame: CGRect.zero, style: .grouped)
        self.tableView.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.tableView.register(TaskDetailCell.self, forCellReuseIdentifier: cellId)
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerId)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return 1
        case 1: return 3
        default: return 3
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TaskDetailCell
        switch indexPath.section {
        case 0: setupCellForSection0(cell: cell)
        case 1: setupCellForSection1(cell: cell, row: indexPath.row)
        default: setupCellForSection2(cell: cell, row: indexPath.row)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 0 {
            showChatLogForTask()
        }
        
        if indexPath.section == 2 && indexPath.row == 1 {
            showEditTask()
        }

        if indexPath.section == 2 && indexPath.row == 2 {
            showDeleteAlert()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let text = task?.text
        let height = MyObject.instance().estimateFrameForText(text: text!, width: view.frame.width - 20, height: 1000).height
        if indexPath.section == 0 && indexPath.row == 0 {
            return height + 16 }
        return 50
    }
    
    func showEditTask() {
        let addTask = AddTaskController()
        if task?.toId?.range(of: "Group") == nil {
            MyObject.instance().userId = task?.toId }
        else if task?.toId?.range(of: "Group") != nil {
            MyObject.instance().groupId = task?.toId
        }
        MyObject.instance().taskEdit = true
        MyObject.instance().taskId = task?.messageId
        MyObject.instance().taskText = (task?.text)!
        MyObject.instance().userNameFromMessage = (task?.taskReceiver)!
        MyObject.instance().dueDateText = (task?.dueDate)!
        let navController = UINavigationController(rootViewController: addTask)
        self.present(navController, animated: true, completion: nil)
    }
    
    func showChatLogForTask() {
        if let userId = task?.toId {
            if userId.range(of: "Group") == nil {
                let ref = Database.database().reference().child("user").child(userId)
                ref.observeSingleEvent(of: .value, with: {
                    (DataSnapshot) in
                    let dictionary = DataSnapshot.value as! [String: AnyObject]
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    let chatLog = ChatLogController()
                    chatLog.user = user
                    self.navigationController?.pushViewController(chatLog, animated: true)
                })
            } else if userId.range(of: "Group") != nil {
                let ref = Database.database().reference().child("group").child(userId)
                ref.observeSingleEvent(of: .value, with: {
                    (DataSnapshot) in
                    let dictionary = DataSnapshot.value as! [String: AnyObject]
                    let group = Group()
                    group.setValuesForKeys(dictionary)
                    let chatLog = ChatLogController()
                    chatLog.group = group
                    self.navigationController?.pushViewController(chatLog, animated: true)
                })
            }
        }
    }
    
    func showDeleteAlert() {
        let alert = UIAlertController.init(title: "Confirm", message: "Delete this task?", preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction.init(title: "Delete", style: .destructive, handler: {
            (completion) in
            self.handleDeleteTask()
        }))
        present(alert, animated: true, completion: nil)
//        let indexPath = IndexPath(row: 2, section: 2)
//        self.tableView(self.tableView, didDeselectRowAt: indexPath)
    }
    
    func handleDeleteTask() {
        if let uid = Auth.auth().currentUser?.uid, let taskId = task?.messageId, let toId = task?.toId, let fromId = task?.fromId {
            let ref1 = Database.database().reference().child("requested-task").child(uid).child(taskId)
            let ref2 = Database.database().reference().child("user-task").child(uid).child(taskId)
            let ref3 = Database.database().reference().child("user-message").child(fromId).child(toId).child(taskId)
            ref1.removeValue()
            ref2.removeValue()
            ref3.removeValue()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    func setupCellForSection0(cell: TaskDetailCell) {
        cell.taskTextView.isHidden = false
        cell.taskTextView.text = task?.text
    }
    
    func setupCellForSection1(cell: TaskDetailCell, row: Int) {
        cell.leftLogo.isHidden = false
        cell.leftLogoLabel.isHidden = false
        cell.rightLabel.isHidden = false
        cell.leftLogo.image = UIImage(named: leftLogoNameArr[row])
        cell.leftLogoLabel.text = leftLogoLabelArr[row]
        cell.rightLabel.text = rightLabelArr[row]
        if row == 0 {
            cell.rightLabel.textColor = .red
        }
    }
    
    func setupCellForSection2(cell: TaskDetailCell, row: Int) {
        cell.leftLabel.isHidden = false
        cell.rightLogo.isHidden = false
        cell.leftLabel.text = leftLabelArr[row]
        if row == 2 {
            cell.leftLabel.textColor = .red
        } else {
            cell.leftLabel.textColor = .blue
            cell.rightLogo.image = UIImage(named: "LeftRightICO")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0 
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        return view
    }
    
}

class TaskDetailCell: UITableViewCell {
    var leftLogo = UIImageView()
    var leftLogoLabel = UILabel()
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    var taskTextView = UITextView()
    var rightLogo = UIImageView()
    let linkAttributes: [String : Any] = [
        NSForegroundColorAttributeName: UIColor.blue,
        NSUnderlineColorAttributeName: UIColor.clear,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
    
    func setupViews() {
        leftLogo.isHidden = true
        leftLogoLabel.isHidden = true
        leftLabel.isHidden = true
        rightLabel.isHidden = true
        taskTextView.isHidden = true
        taskTextView.isEditable = false
        taskTextView.isSelectable = true
        taskTextView.dataDetectorTypes = UIDataDetectorTypes.all
        taskTextView.linkTextAttributes = linkAttributes
        taskTextView.font = UIFont.systemFont(ofSize: 16)
        taskTextView.textContainerInset = UIEdgeInsetsMake(8, 12, 8, 8)
        rightLogo.isHidden = true
        leftLogo.contentMode = .scaleAspectFill
        leftLogo.clipsToBounds = true
        rightLabel.textAlignment = .right
        rightLogo.contentMode = .scaleAspectFill
        rightLogo.clipsToBounds = true
        
        contentView.addSubview(leftLogo)
        contentView.addSubview(leftLogoLabel)
        contentView.addSubview(leftLabel)
        contentView.addSubview(rightLabel)
        contentView.addSubview(taskTextView)
        contentView.addSubview(rightLogo)
        
        leftLogo.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 10, leftConstant: 12, bottomConstant: 10, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        leftLogoLabel.anchor(contentView.topAnchor, left: leftLogo.rightAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        leftLabel.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 12, rightConstant: 0, widthConstant: 200, heightConstant: 26)
        rightLabel.anchor(contentView.topAnchor, left: nil, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 15, rightConstant: 12, widthConstant: 300, heightConstant: 20)
        rightLogo.anchor(contentView.topAnchor, left: nil, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 15, leftConstant: 12, bottomConstant: 15, rightConstant: 12, widthConstant: 20, heightConstant: 20)
        taskTextView.fillSuperview()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

