//
//  AddTaskController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/20/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class AddTaskController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate, DateViewDelegate, ChatPartnerDelegate {
    lazy var customNavBar = UIView()
    lazy var cancelButton = UIButton()
    lazy var navTitleView = UILabel()
    lazy var doneButton = UIButton()
    lazy var textContainer = UITextView()
    lazy var dueDateLabel = UILabel()
    lazy var chatPartnerName = UILabel()
    lazy var rightImageView1 = UIImageView()
    lazy var rightImageView2 = UIImageView()
    lazy var rightImageView3 = UIImageView()
    lazy var rightImageView4 = UIImageView()
    lazy var numberOfUserLabel = UILabel()
    var myTableView = UITableView()
    let cellId = "cellId"
    var leftViewArray = ["Chat", "Due Date", "Assignee"]
    var taskDate: String = "ABC"
    var requestorName: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.textContainer.becomeFirstResponder()
        getRequestorName()
        self.view.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        self.myTableView.keyboardDismissMode = .interactive
        
        self.view.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.isScrollEnabled = false
        myTableView.register(myCustomCell.self, forCellReuseIdentifier: cellId)
//        setupViews()
        setupKeyBoardObservers()
    }
    
    func setDateText(date: String) {
        self.taskDate = date
        dueDateLabel.text = date
        self.view.reloadInputViews()
    }
    
    func getChatPartnerInfo(name: String) {
        self.chatPartnerName.text = name
        self.chatPartnerName.textColor = .blue
        self.view.reloadInputViews()
    }
    
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillEnd), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            textContainerBottomConstraint?.constant = -(keyboardHeight) - 160
            UIView.animate(withDuration: keyboardDuration!, animations: {
                
                self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardWillEnd(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        textContainerBottomConstraint?.constant = -160
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupViews()
        self.navigationController?.isNavigationBarHidden = true
        }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
        }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! myCustomCell
        cell.leftView.text = leftViewArray[indexPath.row]
        cell.leftView.textColor = .darkText
        cell.leftView.textAlignment = .left
        if indexPath.row == 0 {
        cell.isUserInteractionEnabled = MyObject.instance().userNameFromMessage != "" ? false: true
        }
        if indexPath.row == 1 {
            cell.rightLogo.image = UIImage(named: "CalendarICO")
        } else {
            cell.rightLogo.image = UIImage(named: "LeftRightICO")
        }
        if indexPath.row == 2 {
            if MyObject.instance().taskEdit == true {
                cell.isUserInteractionEnabled = false
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let message = MessageController()
            message.check = 1
            message.delegate = self
            self.navigationController?.pushViewController(message, animated: true)
        } else if indexPath.row == 1 {
        let dateView = DateViewController()
        dateView.delegate = self
            self.navigationController?.pushViewController(dateView, animated: true) 
        } else if indexPath.row == 2 {
            let assignee = AssigneeController()
            MyObject.instance().users = [User]()
            self.navigationController?.pushViewController(assignee, animated: true)
        }
    }
    
    func showMessageController(check: Int) {
        let message = MessageController()
        message.check = check
        self.navigationController?.pushViewController(message, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func handleCancel() {
        textContainer.text = ""
        MyObject.instance().taskEdit = false
        MyObject.instance().rowRef = nil
        MyObject.instance().addTaskSource = "Default"
        MyObject.instance().users = [User]()
        MyObject.instance().taskText = ""
        MyObject.instance().userId = ""
        MyObject.instance().groupId = ""
        MyObject.instance().dueDateText = ""
        MyObject.instance().userNameFromMessage = ""

        self.dismiss(animated: true, completion: nil)
    }
    
    func getRequestorName(){
        if let uid = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference().child("user").child(uid)
            userRef.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                let dictionary = DataSnapshot.value
                let user = User()
                user.setValuesForKeys(dictionary as! [String : Any])
                self.requestorName = user.name
            })
        }
    }
    
    func updateTask() {
        if let taskId = MyObject.instance().taskId {
        let ref1 = Database.database().reference(withPath: "message/\(taskId)/infoDict/text")
        ref1.setValue(textContainer.text)
            
        let ref2 = Database.database().reference(withPath: "message/\(taskId)/infoDict/dueDate")
        ref2.setValue(dueDateLabel.text)
        }
        MyObject.instance().taskText = ""
    }
    
    func uploadTask() {
        let properties: [String: AnyObject] = ["text": textContainer.text! as AnyObject, "dueDate": MyObject.instance().dueDateText as AnyObject, "taskReceiver": MyObject.instance().userNameFromMessage as AnyObject, "taskRequestor": requestorName as AnyObject]
        var properties2: [String: String] = ["a": "a"]
        for i in 0..<MyObject.instance().users.count {
            properties2.updateValue(MyObject.instance().users[i].profileImageUrl!, forKey: String(i))
        }
        let properties3: [String: String] = ["a": "a"]
        let chatLog = ChatLogController()
        chatLog.sendMessageWithProperties(properties: properties, properties2: properties2, properties3: properties3)
        
        textContainer.text = ""
        MyObject.instance().rowRef = nil
        MyObject.instance().addTaskSource = "Default"
        MyObject.instance().taskText = ""
//        MyObject.instance().userId = ""
        MyObject.instance().groupId = ""
        MyObject.instance().dueDateText = ""
        MyObject.instance().userNameFromMessage = ""
    }
    
    func handleDone() {
        if MyObject.instance().taskEdit == true {
            updateTask()
        } else {
            uploadTask()
        }
        
        MyObject.instance().taskEdit = false
        self.dismiss(animated: true, completion: nil)
    }
    
    var textContainerBottomConstraint: NSLayoutConstraint?
    
    func setupViews() {
        customNavBar.backgroundColor = UIColor(r: 5, g: 5, b: 5)
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.setTitleColor(.white, for: .normal)
        cancelButton.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        
        navTitleView.text = "Add Task"
        navTitleView.textColor = .white
        navTitleView.textAlignment = .center
        
        doneButton.setTitleColor(.white, for: .normal)
        doneButton.setTitle("Done", for: .normal)
        doneButton.addTarget(self, action: #selector(handleDone), for: .touchUpInside)
        
        textContainer.backgroundColor = .white
        textContainer.delegate = self
        textContainer.font = UIFont.systemFont(ofSize: 16)
        textContainer.translatesAutoresizingMaskIntoConstraints = false
        textContainer.textContainerInset = UIEdgeInsetsMake(12, 12, 12, 12)
        if MyObject.instance().taskText == "" && (textContainer.text == "" || textContainer.text == "Task decription") {
            textContainer.text = "Task decription"
            textContainer.textColor = .lightGray
        }
        else if MyObject.instance().taskText == "" && textContainer.text != "" && textContainer.text != "Task decription" {
            textContainer.textColor = .darkText
        } else {
            textContainer.text = textContainer.text + MyObject.instance().taskText
            textContainer.textColor = .darkText
        }
        
        chatPartnerName.textColor = MyObject.instance().addTaskSource == "Default" ? UIColor.gray : UIColor.blue
        chatPartnerName.textAlignment = .right
        if MyObject.instance().userNameFromMessage != "" {
            if MyObject.instance().userId == Auth.auth().currentUser?.uid {
                chatPartnerName.text = "My Chat" }
            else {
                chatPartnerName.text = MyObject.instance().userNameFromMessage
            }
        }
        
        dueDateLabel.textColor = .blue
        dueDateLabel.textAlignment = .right
        dueDateLabel.text = MyObject.instance().dueDateText
        
        rightImageView1.layer.cornerRadius = 18
        rightImageView1.layer.masksToBounds = true
        rightImageView2.layer.cornerRadius = 18
        rightImageView2.layer.masksToBounds = true
        rightImageView3.layer.cornerRadius = 18
        rightImageView3.layer.masksToBounds = true
        rightImageView4.layer.cornerRadius = 18
        rightImageView4.layer.masksToBounds = true
        
        numberOfUserLabel.textColor = .white
        numberOfUserLabel.textAlignment = .center
        
        if MyObject.instance().users.count > 0 {
            let users = MyObject.instance().users
            let imageViewArray = [rightImageView1, rightImageView2, rightImageView3, rightImageView4]
            if users.count < 4 {
                for i in 0...users.count - 1 {
                    imageViewArray[i].loadImageUsingCacheWithUrlString(urlString: users[i].profileImageUrl!)
                }
            } else {
                rightImageView1.backgroundColor = .blue
                for i in 0...2 {
                    imageViewArray[i+1].loadImageUsingCacheWithUrlString(urlString: users[i].profileImageUrl!)
                    numberOfUserLabel.text = "+ \(users.count - 3)"
                }
            }
        }
        
        view.addSubview(customNavBar)
        customNavBar.addSubview(cancelButton)
        customNavBar.addSubview(navTitleView)
        customNavBar.addSubview(doneButton)
        
        view.addSubview(textContainer)
        view.addSubview(myTableView)
        view.addSubview(chatPartnerName)
        view.addSubview(dueDateLabel)
        view.addSubview(rightImageView1)
        view.addSubview(rightImageView2)
        view.addSubview(rightImageView3)
        view.addSubview(rightImageView4)
        rightImageView1.addSubview(numberOfUserLabel)
        
        customNavBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 64)
        cancelButton.anchor(nil, left: self.view.leftAnchor, bottom: customNavBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 60, heightConstant: 40)
        navTitleView.anchor(nil, left: self.view.centerXAnchor, bottom: customNavBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: -50, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 40)
        doneButton.anchor(nil, left: nil, bottom: customNavBar.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 40)
        
        textContainer.topAnchor.constraint(equalTo: self.customNavBar.bottomAnchor, constant: 30).isActive = true
        textContainer.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        textContainer.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        textContainerBottomConstraint = textContainer.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -160)
        textContainerBottomConstraint?.isActive = true

        myTableView.anchor(textContainer.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 120)
        
        chatPartnerName.anchor(textContainer.bottomAnchor, left: nil, bottom: nil, right: textContainer.rightAnchor, topConstant: 32, leftConstant: 0, bottomConstant: 0, rightConstant: 36, widthConstant: 150, heightConstant: 20)
        
        dueDateLabel.anchor(textContainer.bottomAnchor, left: nil, bottom: nil, right: textContainer.rightAnchor, topConstant: 72, leftConstant: 0, bottomConstant: 0, rightConstant: 36, widthConstant: 150, heightConstant: 16)
        
        rightImageView1.anchor(textContainer.bottomAnchor, left: nil, bottom: nil, right: textContainer.rightAnchor, topConstant: 102, leftConstant: 0, bottomConstant: 0, rightConstant: 36, widthConstant: 36, heightConstant: 36)
        rightImageView2.anchor(textContainer.bottomAnchor, left: nil, bottom: nil, right: textContainer.rightAnchor, topConstant: 102, leftConstant: 0, bottomConstant: 0, rightConstant: 78, widthConstant: 36, heightConstant: 36)
        rightImageView3.anchor(textContainer.bottomAnchor, left: nil, bottom: nil, right: textContainer.rightAnchor, topConstant: 102, leftConstant: 0, bottomConstant: 0, rightConstant: 120, widthConstant: 36, heightConstant: 36)
        rightImageView4.anchor(textContainer.bottomAnchor, left: nil, bottom: nil, right: textContainer.rightAnchor, topConstant: 102, leftConstant: 0, bottomConstant: 0, rightConstant: 162, widthConstant: 36, heightConstant: 36)
        numberOfUserLabel.fillSuperview()
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if  textContainer.textColor == UIColor.lightGray {
            textContainer.selectedTextRange = textContainer.textRange(from: textContainer.beginningOfDocument, to: textContainer.beginningOfDocument)
//            textContainer.text = "Task description"
            doneButton.isEnabled = false
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        let currentText = textContainer.text as NSString?
        let updatedText = currentText?.replacingCharacters(in: range as NSRange, with: text)
        
        if (updatedText?.isEmpty)! {
            doneButton.isEnabled = false
            textContainer.text = "Task description"
                textContainer.textColor = UIColor.lightGray
            textContainer.selectedTextRange = textContainer.textRange(from: textContainer.beginningOfDocument, to: textContainer.beginningOfDocument)
            return true
        }
            
        else if textContainer.textColor == UIColor.lightGray && !text.isEmpty {
            textContainer.text = nil
            textContainer.textColor = UIColor.darkText
            doneButton.isEnabled = true
        }
        
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textContainer.text.isEmpty {
            textContainer.text = "Task description"
            textContainer.textColor = UIColor.lightGray
            doneButton.isEnabled = false
        }
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textContainer.textColor == UIColor.lightGray {
                textContainer.selectedTextRange = textContainer.textRange(from: textView.beginningOfDocument, to: textContainer.beginningOfDocument)
//                textContainer.text = "Task description"
                doneButton.isEnabled = false
            }
        }
    }

}

class myCustomCell: UITableViewCell {
    lazy var leftView = UILabel()
    lazy var rightLogo = UIImageView()
    
    func setupViews() {
        leftView.textColor = .darkText
        rightLogo.contentMode = .scaleAspectFit
        
        contentView.addSubview(leftView)
        contentView.addSubview(rightLogo)
        
        leftView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        rightLogo.anchor(contentView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 3, widthConstant: 25, heightConstant: 25)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
