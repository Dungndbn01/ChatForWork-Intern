//
//  ChatLogControllerHandler.swift
//  ChatForWork
//
//  Created by Nguyen Dinh Dung on 2017/12/17.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

extension ChatLogController
{
    
    func handleAddTask() {
        let addTask = AddTaskController()
        MyObject.instance().userNameFromMessage = (user != nil ? user?.name : group?.name)!
        if group != nil {
            MyObject.instance().groupId = group?.id
        } else if user != nil {
            MyObject.instance().userId = user?.id
        }
        let navController = UINavigationController(rootViewController: addTask)
        self.present(navController, animated: true, completion: nil)
    }
    
    func handleShowCamera() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        imagePickerController.sourceType = .camera
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func handleShowImage() {
        
    }
    
    func handleShowVoice() {
        
    }
    
    func handleShowLocation() {
        
    }
    
    func handleShowFile() {
        
    }
    
    func setupButtonsProperties() {
        taskButton.setImage(UIImage(named: "Task"), for: .normal)
        taskButton.setTitle("Task", for: .normal)
        taskButton.setTitleColor(.darkText, for: .normal)
        taskButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 30, 0, 0)
        taskButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0)
        taskButton.addTarget(self, action: #selector(handleAddTask), for: .touchUpInside)
        cameraButton.setImage(UIImage(named: "CameraICO"), for: .normal)
        cameraButton.setTitle("Camera", for: .normal)
        cameraButton.setTitleColor(.darkText, for: .normal)
        cameraButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 50, 0, 0)
        cameraButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0)
        cameraButton.addTarget(self, action: #selector(handleShowCamera), for: .touchUpInside)
        cameraRollButton.setImage(UIImage(named: "Camera Roll"), for: .normal)
        cameraRollButton.setTitle("Camera Roll", for: .normal)
        cameraRollButton.setTitleColor(.darkText, for: .normal)
        cameraRollButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 50, 0, 0)
        cameraRollButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0)
        cameraRollButton.addTarget(self, action: #selector(handleShowImage), for: .touchUpInside)
        voiceMessagesButton.setImage(UIImage(named: "Voice Message"), for: .normal)
        voiceMessagesButton.setTitle("Voice Message", for: .normal)
        voiceMessagesButton.setTitleColor(.darkText, for: .normal)
        voiceMessagesButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 40, 0, 0)
        voiceMessagesButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0)
        voiceMessagesButton.addTarget(self, action: #selector(handleShowVoice), for: .touchUpInside)
        locationButton.setImage(UIImage(named: "Location"), for: .normal)
        locationButton.setTitle("Location", for: .normal)
        locationButton.setTitleColor(.darkText, for: .normal)
        locationButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 50, 0, 0)
        locationButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0)
        locationButton.addTarget(self, action: #selector(handleShowLocation), for: .touchUpInside)
        chooseFileButton.setImage(UIImage(named: "Choose File"), for: .normal)
        chooseFileButton.setTitle("Choose File", for: .normal)
        chooseFileButton.setTitleColor(.darkText, for: .normal)
        chooseFileButton.imageEdgeInsets = UIEdgeInsetsMake(-30, 50, 0, 0)
        chooseFileButton.titleEdgeInsets = UIEdgeInsetsMake(40, -30, 0, 0)
        chooseFileButton.addTarget(self, action: #selector(handleShowFile), for: .touchUpInside)
    }
    
    func setupOptionsContainerView() {
        let h = UserDefaults.standard.value(forKey: "keyboardHeight") as! CGFloat
        let taskButtonContainer = UIView()
        let cameraButtonContainer = UIView()
        let cameraRollButtonContainer = UIView()
        let voiceMessagesContainer = UIView()
        let locationButtonContainer = UIView()
        let chooseFileButtonContainer = UIView()
        
        upperStackView = UIStackView(arrangedSubviews: [taskButtonContainer, cameraButtonContainer, cameraRollButtonContainer])
        upperStackView.axis = .horizontal
        upperStackView.distribution = .fillEqually
        
        bottomStackView = UIStackView(arrangedSubviews: [voiceMessagesContainer, locationButtonContainer, chooseFileButtonContainer])
        bottomStackView.axis = .horizontal
        bottomStackView.distribution = .fillEqually
        
        optionsContainer.backgroundColor = .white
        optionsContainer.frame = CGRect(x: 0, y: self.view.frame.height - CGFloat(h), width: self.view.frame.width, height: CGFloat(h))
        
        optionsContainer.addSubview(upperStackView)
        optionsContainer.addSubview(bottomStackView)
        
        taskButtonContainer.addSubview(taskButton)
        cameraButtonContainer.addSubview(cameraButton)
        cameraRollButtonContainer.addSubview(cameraRollButton)
        voiceMessagesContainer.addSubview(voiceMessagesButton)
        locationButtonContainer.addSubview(locationButton)
        chooseFileButtonContainer.addSubview(chooseFileButton)
        
        upperStackView.anchor(optionsContainer.topAnchor, left: optionsContainer.leftAnchor, bottom: optionsContainer.centerYAnchor, right: optionsContainer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        bottomStackView.anchor(optionsContainer.centerYAnchor, left: optionsContainer.leftAnchor, bottom: optionsContainer.bottomAnchor, right: optionsContainer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        taskButton.fillSuperview()
        cameraButton.fillSuperview()
        cameraRollButton.fillSuperview()
        voiceMessagesButton.fillSuperview()
        locationButton.fillSuperview()
        chooseFileButton.fillSuperview()
    }
    
    func setupEmojiView() {
        self.view.addSubview(emoji.view)
        self.addChildViewController(emoji)
        emoji.didMove(toParentViewController: self)
        let h = UserDefaults.standard.value(forKey: "keyboardHeight") as! CGFloat
        emoji.view.frame = CGRect(x: 0, y: self.view.frame.height - CGFloat(h), width: self.view.frame.width, height: CGFloat(h))
    }
    
    func setupToUsersView() {
        self.view.addSubview(partner.view)
        self.addChildViewController(partner)
        partner.didMove(toParentViewController: self)
        let h = UserDefaults.standard.value(forKey: "keyboardHeight") as! CGFloat
        emoji.view.frame = CGRect(x: 0, y: self.view.frame.height - CGFloat(h), width: self.view.frame.width, height: CGFloat(h))
    }
    
    func setupKeyBoardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillEnd), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func handleKeyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
            inputContainerBottomAnchor?.constant = -(keyboardHeight) 
            self.chatLogTableView.frame = CGRect(x: 0, y: 0, width: self.view.frame.width
                , height: self.view.frame.height - keyboardRectangle.height - 100)
            tableViewScroll()
            UIView.animate(withDuration: keyboardDuration!, animations: {
                
            self.view.layoutIfNeeded()
            })
        }
    }
    
    func handleKeyboardDidShow(_ notification: Notification) {
        tableViewScroll()
    }
    
    func handleKeyboardWillEnd(_ notification: Notification) {
        let keyboardDuration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue
        inputContainerBottomAnchor?.constant = 50
        self.chatLogTableView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width
            , height: UIScreen.main.bounds.height - 114)
        inputTextView.removeFromSuperview()
        showEmojiButton.removeFromSuperview()
        showOptionsButton.removeFromSuperview()
        setupInputTextView()
        showEmojiButton.tintColor = .black
        showOptionsButton.tintColor = .black
        UIView.animate(withDuration: keyboardDuration!, animations: {
            self.view.layoutIfNeeded()
        })
    }
    
    func tableViewScroll() {
        if messages.count > 0 {
            let indexPath = NSIndexPath(item: messages.count - 1, section: 0)
            self.chatLogTableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            self.view.layoutIfNeeded() }
    }
    
    func handleTextViewClick() {
        showEmojiButton.removeFromSuperview()
        showOptionsButton.removeFromSuperview()
        inputTextView.removeFromSuperview()
                
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(showKeyBoardButton)
        inputContainerView.addSubview(showEmojiButton)
        inputContainerView.addSubview(showToUserButton)
        inputContainerView.addSubview(showOptionsButton)
        inputContainerView.addSubview(sendButton)
        
        inputTextView.inputView = keyboardView.deleteKey
        
        inputTextView.anchor(inputContainerView.topAnchor, left: inputContainerView.leftAnchor, bottom: inputContainerView.bottomAnchor, right: inputContainerView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 58, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        showKeyBoardButton.anchor(inputContainerView.centerYAnchor, left: inputContainerView.leftAnchor, bottom: inputContainerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 0)
        showEmojiButton.anchor(inputContainerView.centerYAnchor, left: showKeyBoardButton.rightAnchor, bottom: inputContainerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 0)
        showToUserButton.anchor(inputContainerView.centerYAnchor, left: showEmojiButton.rightAnchor, bottom: inputContainerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 0)
        showOptionsButton.anchor(inputContainerView.centerYAnchor, left: showToUserButton.rightAnchor, bottom: inputContainerView.bottomAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 0)
        
        sendButton.anchor(inputContainerView.centerYAnchor, left: nil, bottom: inputContainerView.bottomAnchor, right: inputContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 0)
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        handleTextViewClick()
        emoji.view.removeFromSuperview()
        partner.view.removeFromSuperview()
        optionsContainer.removeFromSuperview()
        sendButton.setTitleColor(.blue, for: .normal)
        return true
    }
    
//    func textFieldDidBeginEditing(_ textField: UITextField){
//        if textField == inputTextView {
//            emoji.view.removeFromSuperview()
//            partner.view.removeFromSuperview()
//            optionsContainer.removeFromSuperview()
//            handleTextViewClick()
//            sendButton.setTitleColor(.blue, for: .normal)
//        }
//    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleTextViewClick()
        emoji.view.removeFromSuperview()
        partner.view.removeFromSuperview()
        optionsContainer.removeFromSuperview()
        return true
    }
    
//    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
//        sendButton.setTitleColor(.blue, for: .normal)
//    }
    
    
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        handleTextViewClick()
//    }
    
//    func textViewDidBeginEditing(_ textView: UITextView) {
//        if  inputTextView.textColor == UIColor.lightGray && inputTextView.text == "Type a message..." {
//            inputTextView.selectedTextRange = inputTextView.textRange(from: (inputTextView.beginningOfDocument), to: (inputTextView.beginningOfDocument))
//            inputTextView.text = "Type a message..."
//            inputTextView.textColor = .lightGray
//        }
//    }
//    
//    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
//        if inputTextView.text != "Type a message..." || inputTextView.textColor != .lightGray {
//            sendButton.setTitleColor(.blue, for: .normal)
//            sendButton.isEnabled = true
//        }
//        handleTextViewClick()
//        return true
//    }
//    
//    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
//        
//        let currentText = inputTextView.text as NSString?
//        let updatedText = currentText?.replacingCharacters(in: range as NSRange, with: text)
//        
//        if (updatedText?.isEmpty)! {
//            inputTextView.text = "Type a message..."
//            inputTextView.textColor = UIColor.lightGray
//            inputTextView.selectedTextRange = inputTextView.textRange(from: (inputTextView.beginningOfDocument), to: (inputTextView.beginningOfDocument))
//            return true
//        }
//            
//        else if inputTextView.textColor == UIColor.lightGray && !text.isEmpty {
//            inputTextView.text = nil
////            if let uid = Auth.auth().currentUser?.uid {
////                let typingCheckRef = Database.database().reference(withPath: "user/\(uid)/isTypingCheck")
////                typingCheckRef.setValue("true")
////                observeUserTypingChange(value: 2)
////            }
//            inputTextView.textColor = UIColor.darkText
//            sendButton.setTitleColor(.blue, for: .normal)
//            sendButton.isEnabled = true
//            return true
//        }
//        
//        return true
//    }
//    
//    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
//        inputTextView.removeFromSuperview()
//        showKeyBoardButton.removeFromSuperview()
//        showEmojiButton.removeFromSuperview()
//        showToUserButton.removeFromSuperview()
//        showOptionsButton.removeFromSuperview()
//        sendButton.removeFromSuperview()
//        
//        showEmojiButton.tintColor = .black
//        showOptionsButton.tintColor = .black
//        setupInputTextView()
//
//        return true
//    }
//    
//    func textViewDidEndEditing(_ textView: UITextView) {
//        if (inputTextView.text.isEmpty) {
//            inputTextView.text = "Type a message..."
//            inputTextView.textColor = UIColor.lightGray
////            sendButton.setTitleColor(.lightGray, for: .normal)
////            sendButton.isEnabled = false
//        }
//    }
//    
//    func textViewDidChangeSelection(_ textView: UITextView) {
//        if self.view.window != nil {
//            if inputTextView.textColor == UIColor.lightGray && inputTextView.text == "Type a message..." {
//                inputTextView.selectedTextRange = inputTextView.textRange(from: textView.beginningOfDocument, to: inputTextView.beginningOfDocument)
//                inputTextView.text = "Type a message..."
//                inputTextView.textColor = .lightGray
//                sendButton.setTitleColor(.lightGray, for: .normal)
//                sendButton.isEnabled = false
////                if let uid = Auth.auth().currentUser?.uid {
////                    let typingCheckRef = Database.database().reference(withPath: "user/\(uid)/isTypingCheck")
////                    typingCheckRef.setValue("false")
////                    observeUserTypingChange(value: 1)
////                }
////                sendButton2.isHidden = false
////                sendButton.isHidden = true
////                handleTextViewClick()
//            } else if inputTextView.textColor == UIColor.lightGray && inputTextView.text != "Type a message..." {
//                inputTextView.textColor = UIColor.darkText
//                sendButton.setTitleColor(.blue, for: .normal)
//                sendButton.isEnabled = true
//            }
//        }
//    }
//    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        var dy: CGFloat?
//        if let changeDict = change {
//            if object as? NSObject == self.inputTextView && keyPath == "contentSize" {
//                if let oldContentSize = (changeDict[NSKeyValueChangeKey.oldKey] as AnyObject).cgSizeValue,
//                    let newContentSize = (changeDict[NSKeyValueChangeKey.newKey] as AnyObject).cgSizeValue {
//
//                    if ((inputContainerViewHeightAnchor?.constant)! > CGFloat(150)) && (newContentSize.height - oldContentSize.height > 0) {
//                        dy = 0
//                    } else {
//                        dy = newContentSize.height - oldContentSize.height
//                    }
//
//                    if newContentSize.height > 130 && dy! < CGFloat(0) {
//                        dy = 0
//                    }
//
//                    inputContainerViewHeightAnchor?.constant = (inputContainerViewHeightAnchor?.constant)! + dy!
//
//                    if (inputContainerViewHeightAnchor?.constant)! < CGFloat(100) {
//                        inputContainerViewHeightAnchor?.constant = 100
//                    }
//
////                    self.collectionView?.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: (self.collectionView?.frame.height)! - dy!)
//                    self.view.layoutIfNeeded()
//                    let contentOffsetToShowLastLine = CGPoint(x: 0.0, y: self.inputTextView.contentSize.height - view.bounds.height)
//                    self.inputTextView.contentOffset = contentOffsetToShowLastLine
//                }
//            }
//        }
//    }

}
