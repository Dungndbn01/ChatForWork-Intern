//
//  Message.swift
//  ChatApp
//
//  Created by Nguyen Dinh Dung on 2017/10/26.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    
    var fromId: String?
    var text: String?
    var timeStamp: NSNumber?
    var toId: String?
    var negativeTimeStamp: NSNumber?
    
    var imageUrl: String?
    
    var imageHeight: NSNumber?
    var imageWidth: NSNumber?
    var audioDuration: NSNumber?
    
    var videoUrl: String?
    var audioUrl: String?
    var messageId: String?
    var messageStatus: String?
    var dueDate: String?
    var taskReceiver: String?
    var taskRequestor: String?
    var urlDict: [String: String]?
    var nameDict: [String: String]?
    
    func chatPartnerId() -> String? {
        return fromId == Auth.auth().currentUser?.uid ? toId : fromId
    }
    
    init(dictionary1: [String: AnyObject], dictionary2: [String: String]?, dictionary3: [String: String]?) {
        super.init()
        
        fromId = dictionary1["fromId"] as? String
        text   = dictionary1["text"] as? String
        timeStamp = dictionary1["timeStamp"] as? NSNumber
        toId = dictionary1["toId"] as? String
        negativeTimeStamp = dictionary1["negativeTimeStamp"] as? NSNumber
        messageId = dictionary1["messageId"] as? String
        messageStatus = dictionary1["messageStatus"] as? String
        dueDate = dictionary1["dueDate"] as? String
        taskReceiver = dictionary1["taskReceiver"] as? String
        taskRequestor = dictionary1["taskRequestor"] as? String
        
        imageUrl = dictionary1["imageUrl"] as? String
        imageHeight = dictionary1["imageHeight"] as? NSNumber
        imageWidth = dictionary1["imageWidth"] as? NSNumber
        videoUrl = dictionary1["videoUrl"] as? String
        audioUrl = dictionary1["audioUrl"] as? String
        audioDuration = dictionary1["audioDuration"] as? NSNumber
        
        nameDict = dictionary2
        urlDict = dictionary3
    }
    
}
