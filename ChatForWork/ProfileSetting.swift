//
//  ProfileSetting.swift
//  ChatForWork
//
//  Created by DevOminext on 12/19/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class ProfileSetting: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    let cellId = "cellId"
    let height = UIScreen.main.bounds.height
    let width = UIScreen.main.bounds.width
    var titleArray = [String]()
    var nameArray = [String]()
    lazy var customNavBar = UIView()
    lazy var cancelButton = UIButton()
    lazy var titleLabel = UILabel()
    lazy var saveButton = UIButton()
     var inputTextField = UITextField()
     var okButton = UIButton()
    var infoTable = UITableView()
    var user: User?
    var row: Int?

    override func viewDidLoad() {
        super.viewDidLoad()
        user = MyObject.instance().myProfileUser
        setupTitleAndName(user: user!)
        setupCustomNavBar()

        infoTable.dataSource = self
        infoTable.delegate = self
        infoTable.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        infoTable.register(ProfileSettingCustomCell.self, forCellReuseIdentifier: cellId)
    }

    @objc private func handleDismiss() {
        self.dismiss(animated: true, completion: nil)
    }

    @objc private func handleSaveInfo() {
        let values = ["name": nameArray[0], "email": user?.email!, "profileImageUrl": user?.profileImageUrl!, "checkOnline": user?.checkOnline!, "backgroundImageUrl": user?.backgroundImageUrl!, "id": user?.id!, "lastTimeLoggin": user?.lastTimeLoggin!, "lastTimeLogout": user?.lastTimeLogout!, "isTypingCheck": "false", "chattingWith": "NoOne", "chatId": nameArray[1], "organization": nameArray[2], "team": nameArray[3], "jobTitle": nameArray[4], "address": nameArray[5], "url": nameArray[6], "workPhone": nameArray[8], "userExtension": nameArray[9], "mobile": nameArray[10]] as [String : Any]
        let ref = Database.database().reference().child("user").child((user?.id)!)
        ref.updateChildValues(values, withCompletionBlock: {
            (error ,ref) in
            if error != nil {
                print(error!)
                return
            }
        })

        handleDismiss()

    }

    private func setupCustomNavBar() {
        customNavBar.backgroundColor = UIColor(r: 5, g: 5, b: 5)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(handleDismiss), for: .touchUpInside)

        titleLabel.text = "Edit Profile"
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white

        saveButton.setTitle("Save", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.addTarget(self, action: #selector(handleSaveInfo), for: .touchUpInside)

        view.addSubview(customNavBar)
        view.addSubview(infoTable)
        customNavBar.addSubview(cancelButton)
        customNavBar.addSubview(titleLabel)
        customNavBar.addSubview(saveButton)

        customNavBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 64)
        cancelButton.anchor(nil, left: self.view.leftAnchor, bottom: customNavBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 40)
        titleLabel.anchor(nil, left: self.view.centerXAnchor, bottom: customNavBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: -50, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 40)
        saveButton.anchor(nil, left: nil, bottom: customNavBar.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 40)
        infoTable.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 64, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }

    private func setupTitleAndName(user: User) {
        titleArray = ["Name :","ChatWorkID :","Organization :", "Team :", "Job Title :", "Address :", "URL :", "Email :", "Work Phone :", "Extension :", "Mobile :"]
        nameArray = [(user.name)!,(user.chatId)!,(user.organization)!, (user.team)!, (user.jobTitle)!, (user.address)!, (user.url)!, (user.email)!, (user.workPhone)!, (user.userExtension)!, (user.mobile)!]
        MyObject.instance().array = nameArray
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ProfileSettingCustomCell
        cell.detailTitle.text = titleArray[indexPath.row]
        cell.detailName.text = nameArray[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row = indexPath.row
        MyObject.instance().myProfileTitle = titleArray[row!]
        MyObject.instance().myProfileName = nameArray[row!]
        MyObject.instance().myProfileRow = row!
        showInfoSetting()
    }
    
    func showInfoSetting() {
        let info = InfoSetting()
        info.delegate = self
        self.present(info, animated: true, completion: nil)
    }

    func tableView(_ taleView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }

    func handleUpdate() {
        nameArray[row!] = self.inputTextField.text!
        infoTable.reloadData()
    }

}

class ProfileSettingCustomCell: UITableViewCell, UITextViewDelegate {
    lazy var detailTitle = UILabel()
    lazy var detailName = UILabel()
    func setupViews() {
        detailTitle.textAlignment = .left
        detailTitle = detailTitle.setUpLabel(labelText: "", textColor: .darkText, size: 16)

        detailName.textAlignment = .right
        detailName.textColor = .lightGray
        detailName.backgroundColor = .clear
        detailName.font = UIFont.systemFont(ofSize: 16)

        contentView.addSubview(detailTitle)
        contentView.addSubview(detailName)

        detailTitle.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 20)
        detailName.anchor(contentView.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 200, heightConstant: 20)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)

        setupViews()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class InfoSetting: UIViewController {
    lazy var navBar = UIView()
    lazy var navLeftButton = UIButton()
    lazy var navTitleLabel = UILabel()
    lazy var infoTextField = UITextField()
    var delegate: InfoSettingDelegate?
    
    var navTitle: String?
    var infoString: String?
    override func viewDidLoad() {
        super.viewDidLoad()
        let title = MyObject.instance().myProfileTitle
        let endIndex = title?.index((title?.endIndex)!, offsetBy: -2)
        let truncated = title?.substring(to: endIndex!)
        navTitle = truncated
        infoString = MyObject.instance().myProfileName
        MyObject.instance().myProfileTitle = nil
        MyObject.instance().myProfileName = nil
        setupViews()
        infoTextField.becomeFirstResponder()
        self.view.backgroundColor = UIColor(r: 235, g: 235, b: 235)
    }
    
    func handleBack() {
        delegate?.setupInfo(info: infoTextField.text!, i: MyObject.instance().myProfileRow!)
        MyObject.instance().myProfileRow = nil
        self.dismiss(animated: true, completion: nil)
    }
    
    func setupViews() {
        navBar.backgroundColor = UIColor(r: 5, g: 5, b: 5)
        view.addSubview(navBar)
        navBar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 64)
        
        navLeftButton.setTitle("OK", for: .normal)
        navLeftButton.setTitleColor(.white, for: .normal)
        navLeftButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        navTitleLabel.text = navTitle
        navTitleLabel.textColor = .white
        navTitleLabel.textAlignment = .center
        
        navBar.addSubview(navLeftButton)
        navBar.addSubview(navTitleLabel)
        
        navLeftButton.anchor(nil, left: self.view.leftAnchor, bottom: navBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 40)
        navTitleLabel.anchor(nil, left: self.view.centerXAnchor, bottom: navBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: -100, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 40)
        
        
        infoTextField.text = infoString
        infoTextField.backgroundColor = .white
        view.addSubview(infoTextField)
        
        infoTextField.anchor(navBar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 50)
    }
}

protocol InfoSettingDelegate: class {
    func setupInfo(info: String, i: Int)
}

extension ProfileSetting: InfoSettingDelegate {
    func setupInfo(info: String, i: Int) {
        self.nameArray[i] = info
        self.infoTable.reloadData()
    }
}




