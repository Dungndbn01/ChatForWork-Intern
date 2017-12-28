//
//  TabBarController.swift
//  ChatApp
//
//  Created by Nguyen Dinh Dung on 2017/11/09.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class MainViewController: UITabBarController, UITabBarControllerDelegate, UISearchControllerDelegate, UISearchBarDelegate {
    
    var filterData = [User]()
    var user: User?
    
//    func setupReceivedMessage() {
//        guard let uid = Auth.auth().currentUser?.uid else {
//            return
//        }
//
//        let allUserMessageRef = Database.database().reference().child("user-message").child(uid)
//        allUserMessageRef.observe(.childAdded, with: {
//            (DataSnapshot) in
//            let userId = DataSnapshot.key
//            let userMessageRef = Database.database().reference().child("user-message").child(uid).child(userId)
//            userMessageRef.observe(.childAdded, with: {
//                (DataSnapshot) in
//                let messageId = DataSnapshot.key
//                let messageRef = Database.database().reference().child("message").child(messageId)
//                messageRef.observeSingleEvent(of: .value, with: {
//                    (DataSnapshot) in
//                    guard let dictionary = DataSnapshot.value as? [String: AnyObject] else {
//                        return
//                    }
//
//                    let message = Message(dictionary: dictionary)
//
//                    if message.fromId != Auth.auth().currentUser?.uid && message.messageStatus != "Seen" {
//                        let messageStatusRef = Database.database().reference(withPath: "message/\(messageId)/infoDict/messageStatus")
//
//                        messageStatusRef.setValue("Received")
//                    }
//                })
//            }, withCancel: nil)
//        }, withCancel: nil)
//
//    }
    
    func timeNow() -> NSNumber{
        let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        return timeStamp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMyProfileImageView()
//        setupReceivedMessage()
        setupUserLoginState()
        setupNavBar()
    }
    
    func getMyProfileImageView() {
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference().child("user").child(uid)
            userRef.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                let dictionary = DataSnapshot.value as! [String: AnyObject]
                MyObject.instance().myProfileImageUrl = dictionary["profileImageUrl"] as? String
            })
        }
    }
    
    func setupUserLoginState() {
        if let uid = Auth.auth().currentUser?.uid {
            
            let ref = Database.database().reference().child("user").child(uid).child("checkOnline")
            let lastLogginRef = Database.database().reference(withPath: "user/\(uid)/lastTimeLoggin")
            
            ref.setValue("Connected")
            lastLogginRef.setValue(timeNow())
            
            ref.onDisconnectSetValue("Disconnect")
        }
        //        setupReceivedMessage()
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference(withPath: "user/\(uid)/checkOnline")
            ref.setValue("Connected") }

    }
    
    func setupNavBar() {
        self.navigationItem.title = "Messages"
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
        self.delegate = self
        setupNavBarButton(imageName: "dotsss")
        nameSeparator.frame = CGRect(x: 0, y: self.view.frame.height - 42, width: self.view.frame.width, height: 2)
    }
    
    let userDefault = UserDefaults.standard
    let blackView = UIView()
    
    let nameSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let searchTextField = UITextField(frame: CGRect(x: 58, y: 0, width: UIScreen.main.bounds.width - 116, height: 60))
    
    func setupNavBarButton(imageName: String) {
//        let searchImage = UIImage(named: "search")?.withRenderingMode(.alwaysTemplate)
//        let searchBarButtonItem = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(handleMore))
//        searchBarButtonItem.tintColor = UIColor.white
        let moreImage = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        var moreBarButtonItem = UIBarButtonItem()
        if imageName == "dotsss" {
             moreBarButtonItem = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(handleMore)) }
        moreBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = moreBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
//        navigationItem.leftBarButtonItem = searchBarButtonItem
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
    }
    
    lazy var settingLauncher: SettingLauncher = {
        let launcher = SettingLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    func handleMore() {
        settingLauncher.showSetting()
    }
    
    func showControllerForSettings(setting: Setting){
        let dummySettingsViewController = UIViewController()
        dummySettingsViewController.view.backgroundColor = UIColor.blue
        dummySettingsViewController.navigationItem.title = setting.name.rawValue
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        navigationController?.pushViewController(dummySettingsViewController, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) //This will hide the keyboard
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let item1 = MessageController()
        let icon1 = UITabBarItem(title: "Chat", image: UIImage(named: "Chaticon"), selectedImage: UIImage(named: "Chaticon"))
        item1.tabBarItem = icon1
        
        let item2 = TaskController()
        let icon2 = UITabBarItem(title: "Task", image: UIImage(named: "taskicon"), selectedImage: UIImage(named: "taskicon"))
        item2.tabBarItem = icon2
        
        let item3 = ContactsController()
        let icon3 = UITabBarItem(title: "Contacts", image: UIImage(named: "about"), selectedImage: UIImage(named: "about"))
        item3.tabBarItem = icon3
        
        let item4 = UserProfileController()
        let icon4 = UITabBarItem(title: "Account", image: UIImage(named: "account_icon"), selectedImage: UIImage(named: "account_icon"))
        item4.tabBarItem = icon4
                
        self.tabBarItem.imageInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        let controllers = [item1,item2,item3,item4]  //array of the root view controllers displayed by the tab bar interface
        self.viewControllers = controllers
    }
    
    //Delegate methods
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        return true
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        let indexOfTab = tabBar.items?.index(of: item)
        switch Int(indexOfTab!) {
        case 1: setupNavBarButton(imageName: "PlusICO")
        self.navigationItem.title = "Tasks"
        case 2: setupNavBarButton(imageName: "PlusICO")
        self.navigationItem.title = "Contacts"
        case 3: setupNavBarButton(imageName: "setting")
        self.navigationItem.title = "Account"
        default: setupNavBarButton(imageName: "dotsss")
        self.navigationItem.title = "Messages"
        }
    }
}

class ViewController2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .blue
    }
}

