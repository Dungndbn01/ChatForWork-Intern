//
//  MessageController.swift
//  ChatForWork
//
//  Created by Nguyen Dinh Dung on 2017/12/18.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

protocol ChatPartnerDelegate: class {
    func getChatPartnerInfo(name: String)
}

class MessageController: UITableViewController, UITextFieldDelegate {
    
    let cellId = "cellId"
    var check: Int?
    var delegate: ChatPartnerDelegate?
    var rowRef: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeUserMessage()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        if check == 1 {
            print(check!)
            self.navigationItem.title = "Select Chat"
        }
        
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let message = self.messages[indexPath.row]
        
        if let chatPartnerId = message.chatPartnerId() {
            Database.database().reference().child("user-message").child(uid).child(chatPartnerId).removeValue(completionBlock: {
                [unowned self] (error, ref) in
                if error != nil {
                    print(error!)
                    return
                }
                self.messageDictionary.removeValue(forKey: chatPartnerId)
                self.messages.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath as IndexPath], with: .automatic)
                //                self.handleReloadTable()
                self.tableView.reloadData()
            })
        }
    }
    
    var messages = [Message]()
    var messageDictionary = [String: Message]()
    
    func observeUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        
        let ref = Database.database().reference().child("user-message").child(uid)
        ref.keepSynced(true)
        ref.observe(.childAdded, with: {
            (DataSnapshot) in
            let receiverId = DataSnapshot.key
            let ref2 = Database.database().reference().child("user-message").child(uid).child(receiverId)
            ref2.keepSynced(true)
            ref2.observe(.childAdded, with: {
                [weak self] (DataSnapshot) in
                let messageId = DataSnapshot.key
                let messageReference = Database.database().reference().child("message").child(messageId).child("infoDict")
                messageReference.observeSingleEvent(of: .value, with: { [weak self]
                    (DataSnapshot) in
                    
                    if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                        let message = Message(dictionary1: dictionary, dictionary2: ["0":"0" as String], dictionary3: ["0": "0" as String])
                        message.setValuesForKeys(dictionary)
                        
                        if message.fromId == Auth.auth().currentUser?.uid {
                            self?.messageDictionary[message.toId!] = message
                        } else if message.fromId != Auth.auth().currentUser?.uid {
                            if message.toId?.range(of: "Group") != nil {
                                self?.messageDictionary[message.toId!] = message
                            } else {
                                self?.messageDictionary[message.fromId!] = message }
                        }
                        
                        self?.timer?.invalidate()
                        
                        self?.timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self?.handleReloadTable), userInfo: nil, repeats: false)
                    }
                    
                    }, withCancel: nil)
                }, withCancel: nil)
        }, withCancel: nil)
    }
    
    var timer: Timer?
    var timer2: Timer?
    
    func handleReloadTable() {
        //this will crash because of background thread, so lets call this on dispatch_async main thread
        self.messages = Array(self.messageDictionary.values)
        
        self.messages.sort(by: {
            (message1, message2) -> Bool in
            return (message1.timeStamp?.intValue)! > (message2.timeStamp?.intValue)!
        })
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell1 = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath as IndexPath) as! UserCell
        let message1 = messages[indexPath.row]
        cell1.message = message1
        setupMessageCell(message: message1, cell: cell1)
        cell1.onlineView.removeFromSuperview()
        cell1.callVideoButton.removeFromSuperview()
        cell1.callButton.removeFromSuperview()
        cell1.addFriendButton.removeFromSuperview()
        cell1.cancelFriendButton.removeFromSuperview()
        
        if self.check == 1 {
            cell1.timeLabel.removeFromSuperview()
            if indexPath.row == MyObject.instance().rowRef {
                cell1.tickButton.isHidden = false
            }
        }
        
        cell1.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        return cell1
    }
    
    func getInfoFromRow(row: Int) {
        let message = messages[row]
        MyObject.instance().messageRef = message
        if message.toId?.range(of: "Group") == nil {
        let userId = message.chatPartnerId()
            MyObject.instance().userId = userId
            let ref = Database.database().reference().child("user").child(userId!)
            ref.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                let dictionary = DataSnapshot.value as! [String: AnyObject]
                MyObject.instance().userNameFromMessage = dictionary["name"] as! String
                self.navigationController?.popViewController(animated: true)
            })
        } else {
            let groupId = message.toId
            MyObject.instance().groupId = groupId
            let ref = Database.database().reference().child("group").child(groupId!)
            ref.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                let dictionary = DataSnapshot.value as! [String: AnyObject]
                let groupName = dictionary["name"] as! String
                MyObject.instance().userNameFromMessage = "Group: \(groupName)"
                self.navigationController?.popViewController(animated: true)
            })
            
        }
    }
    
    private func setupMessageCell(message: Message, cell: UserCell){
        if check == 1 {
                cell.detailTextLabel?.isHidden = true
        } else if check != 1 {
            cell.detailTextLabel?.isHidden = false
        if message.fromId == Auth.auth().currentUser?.uid && message.messageStatus == "Sent" {
            cell.timeLabel.text = "Sent"
        } else if message.fromId != Auth.auth().currentUser?.uid && message.messageStatus != "Seen" {
            message.messageStatus = "Received"
        }
        
        if message.fromId == Auth.auth().currentUser?.uid {
            if message.audioDuration != nil {
                cell.detailTextLabel?.text = "You have sent audio"
            }
            if message.videoUrl != nil {
                cell.detailTextLabel?.text = "You have sent video"
            } else {
                if message.imageUrl != nil {
                    cell.detailTextLabel?.text = "You have sent photo"
                } }
            if message.text != nil {
                cell.detailTextLabel?.text = "You: \(message.text ?? "")" }
            cell.detailTextLabel?.textColor = UIColor.darkGray  } else
            if message.fromId != Auth.auth().currentUser?.uid {
                if message.audioDuration != nil {
                    cell.detailTextLabel?.text = " have sent you audio"
                }
                if message.videoUrl != nil {
                    cell.detailTextLabel?.text = " have sent you video"
                } else {
                    if message.imageUrl != nil {
                        cell.detailTextLabel?.text = " have sent you photo"
                    } }
                if message.text != nil {
                    cell.detailTextLabel?.text = message.text }
                
                //            cell.detailTextLabel?.textColor = UIColor.darkGray
                if message.messageStatus == "Received" && message.fromId != Auth.auth().currentUser?.uid {
                    cell.detailTextLabel?.textColor = .blue
                } else { cell.detailTextLabel?.textColor = UIColor.darkGray }
            } }
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        if check != 1 {
        let navigationController = self.navigationController
        if message.toId?.range(of: "Group") == nil {
            guard let chatPartnerId = message.chatPartnerId() else {
                return
            }

            let ref = Database.database().reference().child("user").child(chatPartnerId)
            ref.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                guard let dictionary = DataSnapshot.value as? [String: AnyObject]
                    else {
                        return
                }
                let user = User()
                user.id = chatPartnerId
                user.setValuesForKeys(dictionary)
                MyObject.instance().chattingUser = user
//                MyObject.instance().userId = user.id
                MyObject.instance().chattingGroup = nil
//                MyObject.instance().groupId = nil
                MyObject.instance().showChatControllerForUser(user: user, navigationController: navigationController!)
                }, withCancel: nil) }
        else if message.toId?.range(of: "Group") != nil {
            let ref = Database.database().reference().child("group").child(message.toId!)
            ref.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                guard let dictionary = DataSnapshot.value as? [String: AnyObject]
                    else {
                        return
                }
                let group = Group()
                group.setValuesForKeys(dictionary)
                MyObject.instance().chattingGroup = group
//                MyObject.instance().groupId = group.id
                MyObject.instance().chattingUser = nil
//                MyObject.instance().userId = nil
                MyObject.instance().showChatControllerForGroups(group: group, navigationController: navigationController!)
                }, withCancel: nil)
            } } else if check == 1 {
            if message.toId?.range(of: "Group") == nil {
                MyObject.instance().userId = message.chatPartnerId()
                MyObject.instance().groupId = ""
            } else {
                MyObject.instance().groupId = message.toId
                MyObject.instance().userId = ""
            }
            delegate?.getChatPartnerInfo(name: "123456")
            MyObject.instance().rowRef = indexPath.row
            getInfoFromRow(row: indexPath.row)
        }
    }
    
    func handleLogout() {
        
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
        
        let loginController = LoginController()
        UIApplication.shared.delegate?.window??.rootViewController = loginController
        UIApplication.shared.delegate?.window??.makeKeyAndVisible()
    }
}

