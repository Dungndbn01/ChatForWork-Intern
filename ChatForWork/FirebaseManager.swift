//
//  SendMessageHandler.swift
//  ChatForWork
//
//  Created by DevOminext on 12/18/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

extension ChatLogController {
    func sendMessageWithProperties(properties: [String: AnyObject], properties2: [String: String], properties3: [String: String]) {
        let ref = Database.database().reference().child("message")
        let childRef = ref.childByAutoId()
        let messageId = childRef.key
        let toId = MyObject.instance().userId != "" ? MyObject.instance().userId : MyObject.instance().groupId
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp: NSNumber = NSNumber(value: Int(NSDate().timeIntervalSince1970))
        let negativeTimeStamp: NSNumber = NSNumber(value: -(Int(NSDate().timeIntervalSince1970)))
        var messageStatus: String?
        
//        if toId == MyObject.instance().userId {
            if MyObject.instance().groupId == "" {

            let userRef = Database.database().reference().child("user").child(toId!)
            userRef.observeSingleEvent(of: .value, with: {( DataSnapshot) in
                let dictionary = DataSnapshot.value as! [String: AnyObject]
                let lastTimeLoggin = dictionary["lastTimeLoggin"] as! NSNumber
                let lastTimeLogout = dictionary["lastTimeLogout"] as! NSNumber
                let chattingWith = dictionary["chattingWith"] as! String
                
                if chattingWith == fromId {
                    messageStatus = "Seen"
                } else
                { if Int(lastTimeLoggin) <= Int(lastTimeLogout) {
                    messageStatus = "Sent"
                } else if Int(lastTimeLoggin) > Int(lastTimeLogout) {
                    messageStatus = "Received"
                    } }
                
                var values = ["toId": toId!, "fromId": fromId, "timeStamp": timeStamp, "negativeTimeStamp": negativeTimeStamp, "messageId": messageId, "messageStatus": messageStatus!] as [String : AnyObject]
                var values2 = ["ref": "ref"] as [String: String]
                var values3 = ["ref": "ref"] as [String: String]
                
                //append properties dictionary on to values
                //key $0, value $1
                properties.forEach({values[$0] =  $1})
                properties2.forEach({values2[$0] =  $1})
                properties3.forEach({values3[$0] =  $1})
                
                childRef.child("infoDict").updateChildValues(values, withCompletionBlock: {
                    (error ,ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    childRef.child("urlDict").updateChildValues(values2, withCompletionBlock: {
                        (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        childRef.child("nameDict").updateChildValues(values3, withCompletionBlock: {
                            (error, ref) in
                            if error != nil {
                                print(error!)
                                return
                            }
                                if properties["dueDate"] != nil {
                                    let users = MyObject.instance().users
                                    for i in 0..<users.count {
                                        let userTaskRef = Database.database().reference().child("user-task").child(users[i].id!)
                                        userTaskRef.updateChildValues([messageId: 1])
                                    }
                                    MyObject.instance().users = [User]()
                                    let myTaskRef = Database.database().reference().child("requested-task").child(fromId)
                                    
                                    myTaskRef.updateChildValues([messageId: 1])
                            }
                                let userMessaegRef1 = Database.database().reference().child("user-message").child(fromId).child(toId!)
                                let userMessaegRef2 = Database.database().reference().child("user-message").child(toId!).child(fromId)
                            
                                userMessaegRef1.updateChildValues([messageId: 1])
                                userMessaegRef2.updateChildValues([messageId: 1])
                        })
                    })
               })
            })
            
        }   else if MyObject.instance().groupId != "" {
            var values = ["toId": toId!, "fromId": fromId, "timeStamp": timeStamp, "negativeTimeStamp": negativeTimeStamp, "messageId": messageId, "messageStatus": "Sent"] as [String : AnyObject]
            var values2 = ["ref": "ref"] as [String: String]
            var values3 = ["ref": "ref"] as [String: String]

            properties.forEach({values[$0] =  $1})
            properties2.forEach({values2[$0] =  $1})
            properties3.forEach({values3[$0] =  $1})
            
            childRef.child("infoDict").updateChildValues(values, withCompletionBlock: {
                (error ,ref) in
                if error != nil {
                    print(error!)
                    return
                }
                childRef.child("urlDict").updateChildValues(values2, withCompletionBlock: {
                    (error, ref) in
                    if error != nil {
                        print(error!)
                        return
                    }
                    childRef.child("nameDict").updateChildValues(values3, withCompletionBlock: {
                        (error, ref) in
                        if error != nil {
                            print(error!)
                            return
                        }
                        if properties["dueDate"] != nil {
                            let users = MyObject.instance().users
                            for i in 0..<users.count {
                                let userTaskRef = Database.database().reference().child("user-task").child(users[i].id!)
                                userTaskRef.updateChildValues([messageId: 1])
                            }
                            let myTaskRef = Database.database().reference().child("requested-task").child(fromId)
                            
                            myTaskRef.updateChildValues([messageId: 1])
                        }

                let groupUsersRef = Database.database().reference().child("group-users").child(toId!)
                let userMessageRef2 = Database.database().reference().child("user-message").child(toId!)
                groupUsersRef.updateChildValues([fromId: 1])
                userMessageRef2.updateChildValues([messageId: 1])
                
                groupUsersRef.observe(.childAdded, with: {
                    (DataSnapshot) in
                    let userId = DataSnapshot.key
                    let userMessaegRef1 = Database.database().reference().child("user-message").child(userId).child(toId!)
                    userMessaegRef1.updateChildValues([messageId: 1])
                }, withCancel: nil)
            })
                })
            })
        }
    }
    
    func observeUserMessage() {
        guard let uid = Auth.auth().currentUser?.uid else {
            return
        }
        UserDefaults.standard.setValue(user?.checkOnline, forKey: "CheckOnline")
        
        let userMessageRef = (user?.id) == nil ? Database.database().reference().child("user-message").child((group?.id)!) : Database.database().reference().child("user-message").child(uid).child((user?.id)!)
        
        userMessageRef.queryLimited(toLast: 10).observe(.childAdded, with: {
            (DataSnapshot) in
            let messageId  = DataSnapshot.key
            let messageRef1 = Database.database().reference().child("message").child(messageId).child("infoDict")
            messageRef1.observeSingleEvent(of: .value, with: {
                (DataSnapshot1) in
                let dictionary1 = (DataSnapshot1.value as? [String : AnyObject])!
                let messageRef2 = Database.database().reference().child("message").child(messageId).child("nameDict")
                messageRef2.observeSingleEvent(of: .value, with: {
                        (DataSnapshot2) in
                    let dictionary2 = (DataSnapshot2.value as? [String : String])!

                    let messageRef3 = Database.database().reference().child("message").child(messageId).child("urlDict")
                    messageRef3.observeSingleEvent(of: .value, with: {
                        (DataSnapshot3) in
                        let dictionary3 = (DataSnapshot3.value as? [String : String])!
                
                        let message = Message(dictionary1: dictionary1 as [String: AnyObject] , dictionary2: dictionary2 as [String : String] , dictionary3: dictionary3 as [String : String] )
                        
                        DispatchQueue.main.async {
                            let dateString = self.getDateFromMessage(message: message, index: 0)
                            if message.fromId != Auth.auth().currentUser?.uid {
                                let messageStatusRef = Database.database().reference(withPath: "message/\(message.messageId!)/infoDict/messageStatus")
                                messageStatusRef.setValue("Seen")
                            }
                            
                            self.messages.append(message)
                            self.dateStrings.append(dateString)
                            if self.dateStrings.count == 1 || self.dateStrings[self.dateStrings.count - 1] > self.dateStrings[self.dateStrings.count - 2] {
                                self.textForHeaders.append(dateString)
                            }
                            
                            self.chatLogTableView.reloadData()
                            //                    self.chatLogTableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
                            self.tableViewScroll()
                            self.chatLogTableView.layoutIfNeeded()
                        }
                    })
                })
            })
            
            }, withCancel: nil)
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
    
}
