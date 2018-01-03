//
//  NewMessageController.swift
//  ChatApp
//
//  Created by Nguyen Dinh Dung on 2017/10/24.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class UsersListController: UITableViewController {
    var source: String? 
    let cellId: String = "cellId"
    var users = [User]()
    var selectCheck = [Bool]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUser()
        setupNavBar()
        
        tableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        tableView.contentInset = UIEdgeInsetsMake(0, 0, 60, 0)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.backgroundColor = UIColor(r: 235, g: 235, b: 235)
    }
    
    func setupNavBar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.title = "Add Members"
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
    }
    
    func handleSave() {
        let groupId = MyObject.instance().groupId
        for i in 0...selectCheck.count - 1 {
            if selectCheck[i] == true {
                let ref = Database.database().reference().child("group-users").child(groupId!)
                ref.updateChildValues([users[i].id! : 0])
            }
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func fetchUser() {
        Database.database().reference().child("user").observe(.childAdded, with: { (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                if user.id != Auth.auth().currentUser?.uid {
                    self.selectCheck.append(false)
                    self.users.append(user) }
                self.users.sort(by: {
                    (user1, user2) -> Bool in
                    return (user1.name) ?? "" < (user2.name) ?? ""
                })
                DispatchQueue.main.async ( execute: {
                    self.tableView.reloadData()
                } )
            }
            }, withCancel: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath as IndexPath) as! UserCell
        if users.count > 0 {
            
            let user = self.users[indexPath.row]
            cell.user = user
            if user.checkOnline == "Connected" {
                cell.onlineView.backgroundColor = UIColor.green
            } else if user.checkOnline == "Disconnect" {
                cell.onlineView.backgroundColor = UIColor.gray
            }
            
            cell.textLabel?.text = user.name
            cell.detailTextLabel?.text = user.organization
            cell.detailTextLabel?.textColor = .lightGray
            if let profileImageUrl = user.profileImageUrl {
                
                cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl)
            }
        }
        
        if self.source == "Add Member" {
            cell.addFriendButton.isHidden = true
            cell.callButton.isHidden = true
            cell.callVideoButton.isHidden = true
        }
        
        cell.tickButton.isHidden = selectCheck[indexPath.row] == false ? true : false
        cell.backgroundColor = UIColor(r: 250, g: 250, b: 250)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = self.users[indexPath.row]
        if source != "Add Member" {
            showUserProfileController(user: user) }
        else {
            selectCheck[indexPath.row] = !selectCheck[indexPath.row]
            self.tableView.reloadData()
        }
    }
    
    func showUserProfileController(user: User) {
        let userProfileController = UserProfileController()
        MyObject.instance().chattingUser = user
        userProfileController.user = user
        userProfileController.source = "User List"
        navigationController?.pushViewController(userProfileController, animated: true)
    }
    
}

