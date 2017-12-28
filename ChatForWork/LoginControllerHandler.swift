//
//  LogginController_ImageHandle.swift
//  ChatApp
//
//  Created by Nguyen Dinh Dung on 2017/10/25.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

extension LoginController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func handleRegister() {
        SVProgressHUD.show()
        if emailTextField.text! == "" || passwordTextField.text! == "" || nameTextField.text! == "" {
            SVProgressHUD.dismiss()
            self.errorAlert(string: "You must complete all text fields") }
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            return
        }
        
        Auth.auth().createUser(withEmail: email, password: password, completion: { [unowned self] (user, Error) in
            if Error != nil {
                print(Error!)
                SVProgressHUD.dismiss()
                self.errorAlert(string: "Your email is not correct. Please type again")
                return
            } else {
                guard (user?.uid) != nil else {
                    return
                }
                
                //successfully authenticated user
                let imageName = NSUUID().uuidString
                let ref = Storage.storage().reference()
                let storageRef = ref.child("myImage").child("\(imageName).jpg")
                
                if let image = self.profileImage.image, let uploadData = UIImageJPEGRepresentation(image, 0.1) {
                    
                    storageRef.putData(uploadData, metadata: nil, completion: { [unowned self] (metadata, error) in
                        
                        if error != nil {
                            print(error!)
                            return
                        }
                        if let profileImageUrl = metadata?.downloadURL()?.absoluteString {
                            let backgroundImageUrl = "https://firebasestorage.googleapis.com/v0/b/chatforwork-bd3e3.appspot.com/o/myImage%2FB4A8B7BB-FF8C-4D71-A7A1-4A7819774EB1?alt=media&token=342afebc-0393-4802-b475-267a7656028a"
                            let values = ["name": name, "email": email, "profileImageUrl": profileImageUrl, "checkOnline": "Disconnect", "backgroundImageUrl": backgroundImageUrl, "id": (user?.uid)!, "lastTimeLoggin": 0, "lastTimeLogout": 0, "isTypingCheck": "false", "chattingWith": "NoOne", "chatId": "", "organization": "", "team": "", "jobTitle": "", "address": "", "url": "", "workPhone": "", "userExtension": "", "mobile": ""] as [String : Any]
                            self.registerUserIntoDatabaseWithUID(uid: (user?.uid)!, values: values as [String : AnyObject])
                            SVProgressHUD.dismiss()
                            
                        }                }    )
                }
                
            }
        })
    }
    
    private func registerUserIntoDatabaseWithUID(uid: String, values: [String: AnyObject]) {
        let ref = Database.database().reference()
        let usersReference = ref.child("user").child(uid)
        usersReference.updateChildValues(values, withCompletionBlock: { [unowned self] (err, ref) in
            if err != nil {
                print(err!)
                return
            }
            print("Saved user successfully into Firebase db")
            self.errorAlert(string: "You just created account successfully! Please login on the left button")
        })
        //       self.dismiss(animated: true, completion: nil)
        self.nameTextField.text = ""
        self.emailTextField.text = ""
        self.passwordTextField.text = ""
        profileImage.image = UIImage(named: "avatar")
        profileImage2.image = UIImage(named: "camera")
        do {
            try Auth.auth().signOut()
        } catch let logoutError {
            print(logoutError)
        }
    }
    
    func imageTapped()
    {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imageTapped2()
    {
        let imagePicker2 = UIImagePickerController()
        imagePicker2.delegate = self
        imagePicker2.allowsEditing = true
        imagePicker2.sourceType = .camera
        
        present(imagePicker2, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        profileImage.image = pickedImage
        profileImage.contentMode = .scaleToFill
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}




