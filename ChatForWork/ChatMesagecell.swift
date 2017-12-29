//
//  ChatMesagecell.swift
//  ChatForWork
//
//  Created by DevOminext on 12/18/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class ChatMessageCell: UITableViewCell, UITextViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    var message: Message? {
        didSet {
            if message?.dueDate != nil {
                self.setUpTaskView() } else if (message?.nameDict?.count)! > Int(2) {
                self.setUpNamesView() }
                self.fetchUser()
        }
    }
    
    var dateString: String? {
        didSet {
            dateLabel.backgroundColor = .gray
            dateLabel.textColor = .white
            dateLabel.textAlignment = .center
            dateLabel.layer.cornerRadius = 8
            dateLabel.layer.masksToBounds = true
            dateLabel.text = dateString
            contentView.addSubview(dateLabel)
            dateLabel.anchor(contentView.topAnchor, left: contentView.centerXAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: -50, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        }
    }
    
    lazy var profileImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var messageText = UITextView()
    lazy var messageTime = UILabel()
    lazy var headerDate = UILabel()
    lazy var dateLabel = UILabel()
    
    lazy var taskView = UIView()
    lazy var topLabel = UILabel()
    lazy var separatorView = UIView()
    lazy var taskTextView = UITextView()
    var urlCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    
    lazy var nameView = UIView()
    lazy var textView = UITextView()
    var nameCollection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var dueDateLabel = UILabel()
    
    let linkAttributes: [String : Any] = [
        NSForegroundColorAttributeName: UIColor.blue,
        NSUnderlineColorAttributeName: UIColor.clear,
        NSUnderlineStyleAttributeName: NSUnderlineStyle.styleSingle.rawValue]
    
    func setUpNamesView() {
        nameView.backgroundColor = .clear
        nameView.isUserInteractionEnabled = false
        nameView.isHidden = true
        
        contentView.addSubview(nameView)
        nameView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 70, leftConstant: 64, bottomConstant: 12, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        nameCollection.dataSource = self
        nameCollection.delegate = self
        nameCollection.backgroundColor = .clear
        nameCollection.register(NameCell.self, forCellWithReuseIdentifier: "nameCellId")
        nameCollection.contentInset = UIEdgeInsetsMake(4, 8, 4, 8)
        nameCollection.isUserInteractionEnabled = false
        
        textView.text = message?.text
        textView.isSelectable = true
        textView.isEditable = false
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.textContainerInset = UIEdgeInsetsMake(8, 0, 2, 0)
        textView.isUserInteractionEnabled = false
        textView.dataDetectorTypes = UIDataDetectorTypes.all
        textView.linkTextAttributes = linkAttributes
        
        nameView.addSubview(nameCollection)
        nameView.addSubview(textView)
        
        nameCollection.anchor(nameView.topAnchor, left: nameView.leftAnchor, bottom: nil, right: nameView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: CGFloat(((message?.nameDict?.count)! - 2) * 30))
        textView.anchor(nameCollection.bottomAnchor, left: nameView.leftAnchor, bottom: nameView.bottomAnchor, right: nameView.rightAnchor, topConstant: 8, leftConstant: 0, bottomConstant: 8, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    func setUpTaskView() {
        taskView.layer.cornerRadius = 5
        taskView.layer.masksToBounds = true
        taskView.layer.borderWidth = 1
        taskView.layer.borderColor = UIColor.gray.cgColor
        taskView.isHidden = true
        taskView.isUserInteractionEnabled = false
        
        contentView.addSubview(taskView)
        taskView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 70, leftConstant: 64, bottomConstant: 12, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        
        topLabel.text = "Task assigned"
        topLabel.textColor = .darkGray
        topLabel.backgroundColor = UIColor(r: 245, g: 245, b: 245)
        topLabel.layer.borderWidth = 1
        topLabel.layer.borderColor = UIColor.gray.cgColor
        topLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        taskTextView.text = message?.text
        taskTextView.isEditable = false
        taskTextView.isSelectable = true
        taskTextView.font = UIFont.systemFont(ofSize: 16)
        taskTextView.textContainerInset = UIEdgeInsetsMake(8, 4, 2, 4)
        taskTextView.isUserInteractionEnabled = false
        taskTextView.dataDetectorTypes = UIDataDetectorTypes.all
        taskTextView.linkTextAttributes = linkAttributes
        
        separatorView.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        urlCollection.dataSource = self
        urlCollection.delegate = self
        urlCollection.backgroundColor = .white
        urlCollection.register(UrlCell.self, forCellWithReuseIdentifier: "cellId")
        urlCollection.contentInset = UIEdgeInsetsMake(4, 8, 4, 8)
        urlCollection.isUserInteractionEnabled = false

        if let dueDateText = message?.dueDate {
            dueDateLabel.text = "Due Date: \(dueDateText)" }
        dueDateLabel.textColor = .red
        dueDateLabel.font = UIFont.systemFont(ofSize: 12)
        
        let height = (((message?.urlDict?.count)! - 2) / 8 + 1) * 30 + 16
        
        taskView.addSubview(topLabel)
        taskView.addSubview(taskTextView)
        taskView.addSubview(separatorView)
        taskView.addSubview(urlCollection)
        taskView.addSubview(dueDateLabel)
        
        topLabel.anchor(taskView.topAnchor, left: taskView.leftAnchor, bottom: nil, right: taskView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        dueDateLabel.anchor(nil, left: taskView.leftAnchor, bottom: taskView.bottomAnchor, right: taskView.rightAnchor, topConstant: 0, leftConstant: 8, bottomConstant: 8, rightConstant: 4, widthConstant: 0, heightConstant: 15)
        urlCollection.anchor(nil, left: taskView.leftAnchor, bottom: dueDateLabel.topAnchor, right: taskView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 4, rightConstant: 0, widthConstant: 0, heightConstant: CGFloat(height))
        separatorView.anchor(nil, left: taskView.leftAnchor, bottom: urlCollection.topAnchor, right: taskView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        taskTextView.anchor(topLabel.bottomAnchor, left: taskView.leftAnchor, bottom: urlCollection.topAnchor, right: taskView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView == urlCollection {
            return (message?.urlDict?.count)! -  2 }
        
            return (message?.nameDict?.count)! - 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView == urlCollection {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath) as! UrlCell
        if let url = message?.urlDict![String(indexPath.item)] {
            cell.userImageView.loadImageUsingCacheWithUrlString(urlString: url) }
            return cell }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "nameCellId", for: indexPath) as! NameCell

        cell.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        if let name = message?.nameDict![String(indexPath.item)] {
        cell.nameLabel.text = "TO: \(name)"
            cell.nameLabel.textColor = UIColor(r: 72, g: 6, b: 118) }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == urlCollection {
            return CGSize(width: 30, height: 30) }
        return CGSize(width: self.frame.width - 64 - 12, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    private func fetchUser() {
        let userId = message?.fromId
        let ref = Database.database().reference().child("user").child(userId!)
        ref.observeSingleEvent(of: .value, with: {
            (DataSnapshot) in
            if let dictionary = DataSnapshot.value as? [String: AnyObject] {
                let user = User()
                user.setValuesForKeys(dictionary)
                self.setupViews(user: user)
                ref.removeAllObservers()
            }
        })
    }
    
    func getDateFromMessage(message: Message, index: Int) -> String{
        let seconds = message.timeStamp?.doubleValue
        let messageTimeStamp = NSDate(timeIntervalSince1970: seconds!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        let dateFormatter2 = DateFormatter()
        dateFormatter2.dateFormat = "dd/MM/yyyy"
        
        let dateString: String = dateFormatter.string(from: messageTimeStamp as Date)
        let dateString2: String = dateFormatter2.string(from: messageTimeStamp as Date)
        if index == 0 {
            return dateString2 }
        return dateString
    }
    
    func setupViews(user: User) {
        profileImageView.loadImageUsingCacheWithUrlString(urlString: (user.profileImageUrl)!)
        profileImageView.layer.cornerRadius = 20
        profileImageView.layer.masksToBounds = true
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.isUserInteractionEnabled = false
        
        nameLabel.text = user.name
        nameLabel.textColor = .lightGray
        nameLabel.font = UIFont.boldSystemFont(ofSize: 14)
        
        if message?.text != nil {
            messageText.text = message?.text }
        messageText.textColor = .darkText
        messageText.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0)
        messageText.font = UIFont.systemFont(ofSize: 16)
        messageText.isEditable = false
        messageText.isSelectable = true
        messageText.delegate = self
        messageText.backgroundColor = .clear
        messageText.dataDetectorTypes = UIDataDetectorTypes.all
        messageText.linkTextAttributes = linkAttributes
        messageText.isUserInteractionEnabled = true
        
        messageTime.text = self.getDateFromMessage(message: message!, index: 1)
        messageTime.font = UIFont.systemFont(ofSize: 14)
        messageTime.textColor = .lightGray
        messageTime.textAlignment = .right

        contentView.addSubview(profileImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageText)
        contentView.addSubview(messageTime)
        
        profileImageView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 44, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 40, heightConstant: 40)
        nameLabel.anchor(profileImageView.topAnchor, left: profileImageView.rightAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 16)
        messageText.anchor(nameLabel.bottomAnchor, left: profileImageView.rightAnchor, bottom: nil, right: contentView.rightAnchor, topConstant: 4, leftConstant: 8, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 100)
        messageTime.anchor(profileImageView.topAnchor, left: nil, bottom: nil, right: contentView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 100, heightConstant: 16)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(Coder) has not been implemented")
    }

}

class UrlCell: UICollectionViewCell {
    var userImageView = UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        userImageView.layer.cornerRadius = 15
        userImageView.layer.masksToBounds = true
        self.addSubview(userImageView)
        
        userImageView.fillSuperview()
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

class NameCell: UICollectionViewCell {
    var nameLabel = UILabel()
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        self.addSubview(nameLabel)
        
        nameLabel.fillSuperview()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

