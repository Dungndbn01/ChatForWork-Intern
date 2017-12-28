//
//  ViewController4.swift
//  ChatForWork
//
//  Created by Nguyen Dinh Dung on 2017/12/16.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

//class UserProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegateFlowLayout {

class UserProfileController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    lazy var backgroundImageView = UIImageView()
    lazy var profileImageView = UIImageView()
    lazy var nameLabel = UILabel()
    lazy var userIdLabel = UILabel()
    lazy var myChatButton = UIButton()
    lazy var settingsButton = UIButton()
    lazy var userProfileTable = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    lazy var directChatButton = UIButton()
    lazy var backButton = UIButton()
    lazy var separatorView = UIView()
    lazy var deleteButton = UIButton()

    var titleArray = [String]()
    var nameArray = [String]()
    var user: User?
    let cellId = "cellId"
    let footerId = "footerId"
    var checkImageSource: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
//        userProfileTable.dataSource = self
//        userProfileTable.delegate = self
//        userProfileTable.backgroundColor = .white
//        userProfileTable.register(CustomCell.self, forCellWithReuseIdentifier: cellId)
//        userProfileTable.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)

        if user != nil {
        setupTitleAndName(user: user!)
        setupViews(user: user!)
        addViews(user: user!)
            setupColView()
        }
        else if user == nil {
        fectchUser()
            
        }
//        addViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    func setupColView() {
        userProfileTable.dataSource = self
        userProfileTable.delegate = self
        userProfileTable.backgroundColor = .white
        userProfileTable.register(CustomCell.self, forCellWithReuseIdentifier: cellId)
        userProfileTable.register(UICollectionReusableView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: footerId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 9
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! CustomCell
        cell.detailTitle.text = titleArray[indexPath.row]
        cell.detailName.text = nameArray[indexPath.row]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: self.view.frame.width, height: 66)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        if user != nil {
            return CGSize(width: self.view.frame.width, height: 66)
        }
        return .zero
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: footerId, for: indexPath)
        deleteButton = deleteButton.setUpButton(radius: 5, title: "Delete", imageName: "", backgroundColor: .white, fontSize: 16, titleColor: .red)
        deleteButton.layer.borderWidth = 1
        deleteButton.layer.borderColor = UIColor.red.cgColor

        footer.addSubview(deleteButton)
        deleteButton.isHidden = user == nil ? true : false

        deleteButton.anchor(footer.topAnchor, left: footer.leftAnchor, bottom: footer.bottomAnchor, right: footer.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 8, rightConstant: 16, widthConstant: 0, heightConstant: 50)

        return footer
    }
    
    func setupTitleAndName(user: User) {
        titleArray = ["Organization :", "Team :", "Job Title :", "Address :", "URL :", "Email :", "Work Phone :", "Extension :", "Mobile :"]
        nameArray = [(user.organization)!, (user.team)!, (user.jobTitle)!, (user.address)!, (user.url)!, (user.email)!, (user.workPhone)!, (user.userExtension)!, (user.mobile)!]
    }


    private func fectchUser() {
            if let uid = Auth.auth().currentUser?.uid {
            let userRef = Database.database().reference().child("user").child(uid)
            userRef.observeSingleEvent(of: .value, with: {
                (DataSnapshot) in
                let dictionary = DataSnapshot.value as! [String: AnyObject]
                let user = User()
                user.setValuesForKeys(dictionary)
                MyObject.instance().myProfileUser = user
                self.setupTitleAndName(user: user)
                self.setupViews(user: user)
                self.setupColView()
                self.addViews(user: user)
                self.userProfileTable.reloadData()
                userRef.removeAllObservers()
                }, withCancel: nil)
            }
    }

//    func handleZoomTap() {
//        let chatLogController = ChatLogController()
//        let imageView = self.profileImageView
//        chatLogController.performZoomInForStartingImageView(startingImageView: imageView)
//    }
//
//    func handleUploadTap(sourceName: String, index: Int) {
//        let imagePickerController = UIImagePickerController()
//
//        imagePickerController.allowsEditing = false
//        imagePickerController.delegate = self
//        if index == 0 {
//            imagePickerController.sourceType = .photoLibrary }
//        if index == 1 {
//            imagePickerController.sourceType = .camera
//        }
//        if sourceName == "profile" {
//            checkImageSource = 0
//        } else if sourceName == "background" {
//            checkImageSource = 1
//        }
//
//        present(imagePickerController, animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//        if checkImageSource == 1 {
//            self.backgroundImageView.image = pickedImage
//            self.backgroundImageView.contentMode = .scaleToFill }
//        if checkImageSource == 0 {
//            self.profileImageView.image = pickedImage
//            self.profileImageView.contentMode = .scaleToFill
//        }
//        self.uploadToFirebaseStorageUsingImage(image: pickedImage)
//        dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        dismiss(animated: true, completion: nil)
//    }
//
//    func uploadToFirebaseStorageUsingImage(image: UIImage) {
//        let imageName = NSUUID().uuidString
//        let ref = Storage.storage().reference().child("myImage").child(imageName)
//
//        if let uploadData = UIImageJPEGRepresentation(image, 0.1) {
//            ref.putData(uploadData, metadata: nil, completion: {
//                (metadata, error) in
//                if error != nil {
//                    print("Failed to upload data", error!)
//                    return
//                }
//                if let backgroundImageUrl = metadata?.downloadURL()?.absoluteString {
//                    if let uid = Auth.auth().currentUser?.uid {
//                        if self.checkImageSource == 1 {
//                            let presenceRef = Database.database().reference(withPath: "user/\(uid)/backgroundImageUrl")
//                            presenceRef.setValue(backgroundImageUrl)}
//                        if self.checkImageSource == 0 {
//                            let presenceRef = Database.database().reference(withPath: "user/\(uid)/profileImageUrl")
//                            presenceRef.setValue(backgroundImageUrl)
//                        }
//                    }
//                }
//            })        }
//    }

//    func handleBackgroundTap() {
//        let actionSheet = UIAlertController.init(title: "Cover", message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.default, handler: { [unowned self] (action) in
//            self.handleUploadTap(sourceName: "background",index: 1)
//        }))
//        actionSheet.addAction(UIAlertAction.init(title: "Choose From Photos", style: UIAlertActionStyle.default, handler: { [unowned self] (action) in
//
//            self.handleUploadTap(sourceName: "background",index: 0)
//        }))
//        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
//        }))
//        //Present the controller
//        self.present(actionSheet, animated: true, completion: nil)
//    }
//
//    func handleProfileImageTap() {
//        let actionSheet = UIAlertController.init(title: "Avatar", message: nil, preferredStyle: .actionSheet)
//        actionSheet.addAction(UIAlertAction.init(title: "View Profile Picture", style: UIAlertActionStyle.default, handler: { [unowned self] (action) in
//            self.handleZoomTap()
//        }))
//        actionSheet.addAction(UIAlertAction.init(title: "Take Photo", style: UIAlertActionStyle.default, handler: { [unowned self] (action) in
//            self.handleUploadTap(sourceName: "profile",index: 1)
//        }))
//        actionSheet.addAction(UIAlertAction.init(title: "Choose From Photos", style: UIAlertActionStyle.default, handler: { [unowned self] (action) in
//            self.handleUploadTap(sourceName: "profile",index: 0)
//        }))
//        actionSheet.addAction(UIAlertAction.init(title: "Cancel", style: UIAlertActionStyle.cancel, handler: { (action) in
//        }))
//        self.present(actionSheet, animated: true, completion: nil)
//    }

    func showChatControllerDelegate() {
        showChatControllerForUser(user: self.user!)
    }

    func showChatControllerForUser(user: User) {
        let chatLogController = ChatLogController()
        chatLogController.user = user
        MyObject.instance().chattingUser = user
        navigationController?.pushViewController(chatLogController, animated: true)
        let ref = UserProfileController()
        ref.removeFromParentViewController()
    }

    
    @objc private func handleSetting() {
        let profileSetting = ProfileSetting()
//        let navController = UINavigationController(rootViewController: profileSetting)
        self.present(profileSetting, animated: true, completion: nil)
    }

    @objc private func showChatLogControllerDelegate() {
        let user = MyObject.instance().myProfileUser
        let navigationController = self.navigationController
        self.showChatControllerForUser(user: user!, navigationController: navigationController!)
    }

        func showChatControllerForUser(user: User, navigationController: UINavigationController) {
            let chatLogController = ChatLogController()
            chatLogController.user = user
            navigationController.pushViewController(chatLogController, animated: true)
        }

    func setupViews(user: User) {
        if user.backgroundImageUrl != nil {
            backgroundImageView.loadImageUsingCacheWithUrlString(urlString: (user.backgroundImageUrl)!) } else {
                    backgroundImageView.image = UIImage(named: "camera")
    }

        backgroundImageView.isUserInteractionEnabled = user.id == Auth.auth().currentUser?.uid ? true : false
//        let backgroundTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
//        backgroundImageView.addGestureRecognizer(backgroundTapGesture)

        profileImageView.loadImageUsingCacheWithUrlString(urlString: (user.profileImageUrl)!)
        profileImageView.layer.cornerRadius = 25
        profileImageView.layer.masksToBounds = true
        profileImageView.isUserInteractionEnabled = user.id == Auth.auth().currentUser?.uid ? true : false
//        let profileImageTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleProfileImageTap))
//        profileImageView.addGestureRecognizer(profileImageTapGesture)

        nameLabel = nameLabel.setUpLabel(labelText: (user.name)!, textColor: .white, size: 16)
        nameLabel.textAlignment = .center
        userIdLabel = userIdLabel.setUpLabel(labelText: (user.chatId)!, textColor: .white, size: 10)
        userIdLabel.textAlignment = .center

        myChatButton = myChatButton.setUpButton(radius: 5, title: "MyChat", imageName: "", backgroundColor: .white, fontSize: 16, titleColor: .blue)
        myChatButton.layer.borderWidth = 1
        myChatButton.layer.borderColor = UIColor.blue.cgColor
        myChatButton.addTarget(self, action: #selector(showChatLogControllerDelegate), for: .touchUpInside)

        settingsButton = settingsButton.setUpButton(radius: 5, title: "Settings", imageName: "", backgroundColor: .white, fontSize: 16, titleColor: .blue)
        settingsButton.layer.borderWidth = 1
        settingsButton.layer.borderColor = UIColor.blue.cgColor
        settingsButton.addTarget(self, action: #selector(handleSetting), for: .touchUpInside)

        directChatButton = directChatButton.setUpButton(radius: 5, title: "Direct Chat", imageName: "", backgroundColor: .white, fontSize: 16, titleColor: .blue)
        directChatButton.addTarget(self, action: #selector(showChatControllerDelegate), for: .touchUpInside)
        directChatButton.layer.borderWidth = 1
        directChatButton.layer.borderColor = UIColor.blue.cgColor

        backButton.setImage(UIImage(named: "backBT")?.withRenderingMode(.alwaysTemplate), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(popViewController), for: .touchUpInside)

        separatorView.backgroundColor = UIColor(r: 235, g: 235, b: 235)

        self.userProfileTable.isScrollEnabled = true


    }
    
    
    func addViews(user: User) {
        view.addSubview(backgroundImageView)
        view.addSubview(profileImageView)
        view.addSubview(nameLabel)
        view.addSubview(userIdLabel)
        view.addSubview(myChatButton)
        view.addSubview(settingsButton)
        view.addSubview(directChatButton)
        view.addSubview(userProfileTable)
        view.addSubview(backButton)
        view.addSubview(separatorView)
        
        if let uid = Auth.auth().currentUser?.uid {
                myChatButton.isHidden = user.id == uid ? false : true
                settingsButton.isHidden = user.id == uid ? false : true
                directChatButton.isHidden = user.id == uid ? true : false
                backButton.isHidden = user.id == uid ? true : false
            }
        
        backgroundImageView.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 200)
        
                profileImageView.anchor(nil, left: self.view.centerXAnchor, bottom: backgroundImageView.centerYAnchor, right: nil, topConstant: 0, leftConstant: -25, bottomConstant: -10, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        
                nameLabel.anchor(profileImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 12, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
                userIdLabel.anchor(nameLabel.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 20)
        
                myChatButton.anchor(backgroundImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.centerXAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 6, widthConstant: 0, heightConstant: 50)
        
                settingsButton.anchor(backgroundImageView.bottomAnchor, left: self.view.centerXAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 8, leftConstant: 6, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
        
        directChatButton.anchor(backgroundImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 50)
        
        separatorView.anchor(backgroundImageView.bottomAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 65, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 2)
        
        userProfileTable.anchor(backgroundImageView.bottomAnchor, left: self.view.leftAnchor, bottom: self.view.bottomAnchor, right: self.view.rightAnchor, topConstant: 66, leftConstant: 0, bottomConstant: 50, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        backButton.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: nil, topConstant: 30, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 20, heightConstant: 20)

    }

    func popViewController() {
        self.navigationController?.popViewController(animated: true)
    }
}


