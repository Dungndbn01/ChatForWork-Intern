//
//  AssigneeController.swift
//  ChatForWork
//
//  Created by Nguyen Dinh Dung on 2017/12/23.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class AssigneeController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    let message = MyObject.instance().messageRef
    var users = [User]()
    var selectCheck = [Bool]()
    let cellId = "cellId"
    lazy var deselectButton = UIButton()
    lazy var selectAllButton = UIButton()
    var myTableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        fetchUserInfo()
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.register(UserCell.self, forCellReuseIdentifier: cellId)
        
        setupNavBar()
        setupViews()
    }
    
    func fetchUserInfo() {
        let uid = Auth.auth().currentUser?.uid

        if MyObject.instance().userId != nil {
            let userId = MyObject.instance().userId
            let partnerId = userId
            for id in [uid, partnerId] {
                let ref = Database.database().reference().child("user").child(id!)
                ref.observeSingleEvent(of: .value, with: {
                    (DataSnapshot) in
                    let dictionary = DataSnapshot.value as! [String: AnyObject]
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.selectCheck.append(false)
                    self.users.append(user)
                    self.myTableView.reloadData()
                })
            }
        } else if MyObject.instance().groupId != nil {
            let groupId = MyObject.instance().groupId
            let ref = Database.database().reference().child("group-users").child(groupId!)
            ref.observe(.childAdded, with: {
                (DataSnapshot) in
                let userId = DataSnapshot.key
                let userRef = Database.database().reference().child("user").child(userId)
                userRef.observeSingleEvent(of: .value, with: {
                    (DataSnapshot) in
                    let dictionary = DataSnapshot.value as! [String: AnyObject]
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.selectCheck.append(false)
                    self.users.append(user)
                    self.myTableView.reloadData()
                })
            } )
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell
        let user = users[indexPath.row]
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
        cell.textLabel?.text = user.name
        if selectCheck[indexPath.row] == true {
            cell.tickButton.isHidden = false
        } else if selectCheck[indexPath.row] == false {
            cell.tickButton.isHidden = true
        }
        cell.addFriendButton.removeFromSuperview()
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectCheck[indexPath.row] == false {
            selectCheck[indexPath.row] = true
        } else if selectCheck[indexPath.row] == true {
            selectCheck[indexPath.row] = false
        }
        self.myTableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    
    private func setupNavBar() {
        self.navigationItem.title = "Assignee"
        
        let rightBarBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    @objc private func handleDone() {
        for i in 0..<selectCheck.count {
            if selectCheck[i] == true {
                MyObject.instance().users.append(users[i])
            }
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    func handleDeselect() {
        for i in 0..<selectCheck.count {
            selectCheck[i] = false
        }
        
        self.myTableView.reloadData()
    }
    
    func handleSelectAll() {
        for i in 0..<selectCheck.count {
            selectCheck[i] = true
        }
        
        self.myTableView.reloadData()
    }
    
    func setupViews() {
        deselectButton = deselectButton.setUpButton(radius: 5, title: "Deselect", imageName: "", backgroundColor: .white, fontSize: 16, titleColor: .gray)
        deselectButton.layer.borderWidth = 1
        deselectButton.layer.borderColor = UIColor.gray.cgColor
        deselectButton.addTarget(self, action: #selector(handleDeselect), for: .touchUpInside)
        
        selectAllButton = selectAllButton.setUpButton(radius: 5, title: "Select All", imageName: "", backgroundColor: .white, fontSize: 16, titleColor: .blue)
        selectAllButton.layer.borderColor = UIColor.blue.cgColor
        selectAllButton.layer.borderWidth = 1
        selectAllButton.addTarget(self, action: #selector(handleSelectAll), for: .touchUpInside)
        
        view.addSubview(deselectButton)
        view.addSubview(selectAllButton)
        view.addSubview(myTableView)
        
        deselectButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.centerXAnchor, topConstant: 120, leftConstant: 12, bottomConstant: 0, rightConstant: 6, widthConstant: 0, heightConstant: 38)
        selectAllButton.anchor(view.topAnchor, left: view.centerXAnchor, bottom: nil, right: view.rightAnchor, topConstant: 120, leftConstant: 6, bottomConstant: 0, rightConstant: 12, widthConstant: 0, heightConstant: 38)
        
        myTableView.anchor(deselectButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 6, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
}
