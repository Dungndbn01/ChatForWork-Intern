//
//  UserCell.swift
//  ChatApp
//
//  Created by Nguyen Dinh Dung on 2017/10/27.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase
import LBTAComponents

class UserCell: UITableViewCell {
    let date = NSDate()
    let calendar = Calendar.current
    var name: String?
    var user: User?
    
    var message: Message? {
        didSet {
            setupMessageCell()
            setupNameAndProfileImage()
        }
    }
    
        func getCurrentTimeStampWOMiliseconds(dateToConvert: NSDate) -> String {
            let objDateformat: DateFormatter = DateFormatter()
            objDateformat.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let strTime: String = objDateformat.string(from: dateToConvert as Date)
            let objUTCDate: NSDate = objDateformat.date(from: strTime)! as NSDate
            let milliseconds: Int64 = Int64(objUTCDate.timeIntervalSince1970)
            let strTimeStamp: String = "\(milliseconds)"
            return strTimeStamp
        }
    
    func setupMessageCell(){
        if let seconds = message?.timeStamp?.doubleValue {
            
            let now = NSDate()
            let nowTimeStamp = self.getCurrentTimeStampWOMiliseconds(dateToConvert: now)
            
            let timeInterval = Int(nowTimeStamp)! - Int(seconds)
            
            if timeInterval < 60 {
                self.timeLabel.text = String(timeInterval) + " seconds"
            } else if timeInterval > 60 && timeInterval < 3600 {
                let minutes = Int(timeInterval/60)
                self.timeLabel.text = String(minutes) + " minutes"
            } else if timeInterval > 3600 && timeInterval < 86400 {
                let hours = Int(timeInterval/3600)
                self.timeLabel.text = String(hours) + " hours"
            } else if timeInterval > 86400 {
                let days = Int(timeInterval/86400)
                self.timeLabel.text = String(days) + " days"
            }
        }
    }
    
    private func setupNameAndProfileImage() {
        if message?.toId?.range(of: "Group") == nil {
            if let id = message?.chatPartnerId() {
                let ref = Database.database().reference().child("user").child(id)
                ref.observeSingleEvent(of: .value, with: {
                    [unowned self] (DataSnapshot) in
                    
                    if let dictionary = DataSnapshot.value as? [String: AnyObject]
                    {
                        let userId = dictionary["id"] as? String
                        self.textLabel?.text = dictionary["name"] as? String
                        if userId == Auth.auth().currentUser?.uid {
                            self.textLabel?.text = "My Chat"
                        }
                        
                        if let profileImageUrl = dictionary["profileImageUrl"] {
                            self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)
                        }
                    }
                    }, withCancel: nil)
            } }
        else if message?.toId?.range(of: "Group") != nil {
            let ref = Database.database().reference().child("group").child((message?.toId!)!)
            ref.observeSingleEvent(of: .value, with: {
                [unowned self] (DataSnapshot) in
                if let dictionary = DataSnapshot.value as? [String: AnyObject]
                {
                    self.name = dictionary["name"] as? String
                    let text = "Group: " + self.name!
                    self.textLabel?.text = text
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] {
                        self.profileImageView.loadImageUsingCacheWithUrlString(urlString: profileImageUrl as! String)
                    }
                }
                }, withCancel: nil)
        }
    }
    
    func addFriend() {
        addFriendButton.setTitle("Sent request", for: .normal)
        addFriendButton.setTitleColor(.black, for: .normal)
        addFriendButton.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        if let uid = Auth.auth().currentUser?.uid {
            let ref1 = Database.database().reference().child("user-friends").child(uid)
            let ref2 = Database.database().reference().child("user-friends").child((user?.id!)!)
            ref1.updateChildValues([(user?.id)!: 0])
            ref2.updateChildValues([uid:2])
        }
    }
    
    func confirmFriend() {
        setupFriendButton3()
        if let uid = Auth.auth().currentUser?.uid {
            let ref1 = Database.database().reference().child("user-friends").child(uid).child((user?.id)!)
            ref1.setValue(1)
            let ref2 = Database.database().reference().child("user-friends").child((user?.id)!).child(uid)
            ref2.setValue(1)
        }
    }
    
    func handleSentRequest() {
        addFriendButton.setTitle("Add Friend", for: .normal)
        addFriendButton.setTitleColor(.white, for: .normal)
        addFriendButton.backgroundColor = UIColor(r: 61, g: 167, b: 244)
        
        if let uid = Auth.auth().currentUser?.uid {
            let ref1 = Database.database().reference().child("user-friends").child(uid).child((user?.id)!)
            ref1.removeValue()
            let ref2 = Database.database().reference().child("user-friends").child((user?.id)!).child(uid)
            ref2.removeValue()
        }
    }
    
    func handleAddFriend() {
        let buttonText = addFriendButton.titleLabel?.text
        switch buttonText! {
        case "Add Friend": addFriend()
        case "Confirm": confirmFriend()
        case "Sent request": handleSentRequest()
        default:
            return
        }
    }
    
    func handleCancellFriend() {
        handleSentRequest()
        cancelFriendButton.removeFromSuperview()
        addFriendButton.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 16, rightConstant: 12, widthConstant: 100, heightConstant: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 66, y: textLabel!.frame.origin.y, width: textLabel!.frame.width, height: textLabel!.frame.height)
        detailTextLabel?.frame = CGRect(x: 66, y: detailTextLabel!.frame.origin.y, width: self.frame.width - 152, height: detailTextLabel!.frame.height)
    }
    
    lazy var onlineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 3
        view.layer.masksToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var callButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "call_icon_rsz"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        //        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var callVideoButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.clear
        button.setImage(UIImage(named: "camera_icon_rsz"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        //        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        return button
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var arrowImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = UIColor.lightGray
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tickButton: UIButton = {
       let button = UIButton()
        button.setImage(UIImage(named: "CheckICO"), for: .normal)
        button.isHidden = true
        return button
    }()
    
    lazy var nameSeparator: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b:220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var addFriendButton = UIButton()
    lazy var cancelFriendButton = UIButton()
    
    func setupFriendButton() {
        //        self.addSubview(addFriendButton)
        self.addSubview(cancelFriendButton)
        cancelFriendButton.anchor(self.centerYAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 4, rightConstant: 12, widthConstant: 100, heightConstant: 0)
        
        addFriendButton.setTitle("Confirm", for: .normal)
        addFriendButton.anchor(self.topAnchor, left: nil, bottom: self.cancelFriendButton.topAnchor, right: self.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 8, rightConstant: 12, widthConstant: 100, heightConstant: 0)
        
    }
    
    func setupFriendButton2() {
        self.cancelFriendButton.removeFromSuperview()
        self.addFriendButton.setTitle("Sent request", for: .normal)
        self.addFriendButton.setTitleColor(.black, for: .normal)
        self.addFriendButton.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        addFriendButton.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 16, rightConstant: 12, widthConstant: 100, heightConstant: 0)
    }
    
    func setupFriendButton3() {
        self.addFriendButton.removeFromSuperview()
        self.cancelFriendButton.removeFromSuperview()
        self.addSubview(callButton)
        self.addSubview(callVideoButton)
        callButton.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 12, rightConstant: 65, widthConstant: 30, heightConstant: 30)
        
        callVideoButton.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 12, rightConstant: 15, widthConstant: 30, heightConstant: 30)
    }
    
    
    func userFriendsObserver() {
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("user-friends").child(uid)
            ref.observe(.childAdded, with: {
                (DataSnapshot) in
                let userId = DataSnapshot.key
                if userId == self.user?.id {
                    let friendRef = Database.database().reference().child("user-friends").child(uid).child(userId)
                    friendRef.observeSingleEvent(of: .value, with: {
                        [unowned self] (DataSnapshot) in
                        let friendState = DataSnapshot.value as! Int
                        if friendState == 2 {
                            self.setupFriendButton()
                        } else if friendState == 0 {
                            self.setupFriendButton2()
                        } else if friendState == 1 {
                            self.setupFriendButton3()
                        }
                        self.reloadInputViews()
                    }) }
            })
        }
    }
    
    func userFriendsObserver2() {
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("user-friends").child(uid)
            ref.observe(.childChanged, with: {
                (DataSnapshot) in
                let userId = DataSnapshot.key
                let ref1 = Database.database().reference().child("user-friends").child(uid).child(userId)
                ref1.setValue(1)
                let ref2 = Database.database().reference().child("user-friends").child(userId).child(uid)
                ref2.setValue(1)
                self.userFriendsObserver()
            })
        }
    }
    
    func userFriendObserver3() {
        if let uid = Auth.auth().currentUser?.uid {
            let ref = Database.database().reference().child("user-friends").child(uid)
            ref.observe(.childRemoved, with: {
                (DataSnapshot) in
                let userId = DataSnapshot.key
                if userId == self.user?.id {
                    self.cancelFriendButton.removeFromSuperview()
                    self.addFriendButton.setTitle("Add Friend", for: .normal)
                    self.addFriendButton.backgroundColor = UIColor(r: 61, g: 167, b: 244)
                    self.addFriendButton.setTitleColor(.white, for: .normal)
                } })
        }
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addFriendButton = addFriendButton.setUpButton(radius: 3, title: "Add Friend", imageName: "", backgroundColor: UIColor(r: 61, g: 167, b: 244), fontSize: 16, titleColor: .white)
        addFriendButton.addTarget(self, action: #selector(handleAddFriend), for: .touchUpInside)
        cancelFriendButton = cancelFriendButton.setUpButton(radius: 3, title: "Cancel", imageName: "", backgroundColor: UIColor(r: 235, g: 235, b: 235), fontSize: 16, titleColor: .black)
        cancelFriendButton.addTarget(self, action: #selector(handleCancellFriend), for: .touchUpInside)
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(nameSeparator)
        addSubview(arrowImageView)
        addSubview(onlineView)
        addSubview(addFriendButton)
        addSubview(tickButton)
        
        arrowImageView.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 12, rightConstant: 12, widthConstant: 20, heightConstant: 20)
        
        nameSeparator.anchor(nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 66, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        tickButton.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 19, leftConstant: 0, bottomConstant: 19, rightConstant: 12, widthConstant: 30, heightConstant: 30)
        
        //need x,y,width,height constraints
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        // need x,y,width,height constraints
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 88).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
        
        //need x,y,width,height constraints
        onlineView.rightAnchor.constraint(equalTo: self.profileImageView.rightAnchor, constant: 5).isActive = true
        onlineView.bottomAnchor.constraint(equalTo: self.profileImageView.bottomAnchor, constant: 5).isActive = true
        onlineView.heightAnchor.constraint(equalToConstant: 8).isActive = true
        onlineView.widthAnchor.constraint(equalToConstant: 8).isActive = true
        
        addFriendButton.anchor(self.topAnchor, left: nil, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 16, leftConstant: 0, bottomConstant: 16, rightConstant: 12, widthConstant: 100, heightConstant: 0)
        userFriendsObserver()
        userFriendsObserver2()
        userFriendObserver3()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

