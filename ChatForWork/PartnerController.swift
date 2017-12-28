//
//  PartnerController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/25/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

protocol PartnerControllerDelegate: class {
    func appendElement(element: String)
}

class PartnerController: UITableViewController {
    let user = MyObject.instance().chattingUser
    let group = MyObject.instance().chattingGroup
    var users = [User]()
    let cellId = "cellId"
    var delegate: PartnerControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .white
        if user != nil {
            fetchUniqueUser()
        } else if user == nil {
            fetchGroupUsers()
        }
        self.tableView.register(UserCell.self, forCellReuseIdentifier: cellId)

    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return users.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserCell

        let user = users[indexPath.row]
        cell.profileImageView.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl!)
        cell.textLabel?.text = user.name

        cell.addFriendButton.removeFromSuperview()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = getNameFromTable(row: indexPath.row)
        delegate?.appendElement(element: name)
    }
    
    func getNameFromTable(row: Int) -> String{
        return users[row].name!
    }
    
    func fetchUniqueUser() {
        if let userID = user?.id {
            let ref = Database.database().reference().child("user").child(userID)
            ref.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                let dictionary = DataSnapshot.value as! [String: AnyObject]
                let user = User()
                user.setValuesForKeys(dictionary)
                self.users.append(user)
                self.tableView.reloadData()
            })
        }
    }
    
    func fetchGroupUsers() {
        if let groupID = group?.id {
            let ref = Database.database().reference().child("group-users").child(groupID)
            ref.observe(.childAdded, with: {
                (DataSnapshot) in
                let userId = DataSnapshot.key
                if userId != Auth.auth().currentUser?.uid {
                let userRef = Database.database().reference().child("user").child(userId)
                userRef.observeSingleEvent(of: .value, with: {
                    (DataSnapshot) in
                    let dictionary = DataSnapshot.value as! [String: AnyObject]
                    let user = User()
                    user.setValuesForKeys(dictionary)
                    self.users.append(user)
                    self.tableView.reloadData()
                })
                }
            })
        }
    }

}
