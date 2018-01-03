//
//  GroupController.swift
//  ChatForWork
//
//  Created by DevOminext on 1/3/18.
//  Copyright © 2018 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class ChatInfoController: UIViewController {
    lazy var descriptionBT = UIButton()
    lazy var taskBT = UIButton()
    lazy var memberBT = UIButton()
    lazy var fileBT = UIButton()
    lazy var addMemBT = UIButton()
    var group: Group?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavBar()
        setupTopButton()
        view.backgroundColor = .white
    }
    
    func setupNavBar() {
        let leftItem = UIBarButtonItem(title: "Close", style: .done, target: self, action: #selector(handleDismiss))
        navigationItem.title = "Chat Information"
        navigationItem.leftBarButtonItem = leftItem
    }
    
    func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }
 
    func setupTopButton() {
        let textArr = ["Description", "Task", "Member", "File", "Add Members"]
        let btArr = [descriptionBT, taskBT, memberBT, fileBT, addMemBT]
        for bt in btArr {
            bt.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            bt.setTitle(textArr[btArr.index(of: bt)!], for: .normal)
            if bt != addMemBT {
                bt.setTitleColor(.gray, for: .normal)
                bt.layer.borderColor = UIColor.gray.cgColor
            }
            else {
                let uid = Auth.auth().currentUser?.uid
                let ref = Database.database().reference().child("group-users").child((group?.id)!)
                ref.observeSingleEvent(of: .value, with: {
                    (DataSnapshot) in
                    let dictionary = DataSnapshot.value as! [String: Int]
                    if dictionary[uid!] == 1 {
                        bt.isEnabled = true
                        bt.setTitleColor(.blue, for: .normal)
                        bt.layer.borderColor = UIColor.blue.cgColor
                    } else {
                        bt.isEnabled = false
                        bt.setTitleColor(.gray, for: .normal)
                        bt.layer.borderColor = UIColor.gray.cgColor
                    }
            })
                bt.layer.cornerRadius = 5
                bt.layer.masksToBounds = true
            }
            bt.layer.borderWidth = 0.5
        }
        
//        memberBT.addTarget(<#T##target: Any?##Any?#>, action: <#T##Selector#>, for: <#T##UIControlEvents#>)
        addMemBT.addTarget(self, action: #selector(handleAddMember), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [descriptionBT, taskBT, memberBT, fileBT])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        view.addSubview(addMemBT)
        stackView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 64, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 60)
        addMemBT.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 8, rightConstant: 12, widthConstant: 0, heightConstant: 40)
    }
    
    func handleAddMember() {
        let user = UsersListController()
        user.source = "Add Member"
        let navController = UINavigationController(rootViewController: user)
        self.present(navController, animated: true, completion: nil)
    }
}
