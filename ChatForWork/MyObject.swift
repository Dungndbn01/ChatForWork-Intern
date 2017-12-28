//
//  MyObject.swift
//  ChatApp
//
//  Created by DevOminext on 12/15/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

class MyObject: NSObject {
    var myProfileTitle: String?
    var myProfileName: String?
    var myProfileRow: Int?
    var myProfileImageUrl: String?
    var chattingUser : User?
    var chattingGroup : Group?
    var myProfileUser :User?
    var userId: String?
    var groupId: String?
    var rowRef: Int?
    var users = [User]()
    var taskText: String = ""
    var addTaskText: String = ""
    var dueDateText: String = ""
    var userOrgName: String = ""
    var userNameFromMessage: String = ""
    var messageRef: Message!
    var array = [String]()

    static private var share: MyObject?
    class func instance() -> MyObject {
        if share == nil {
            share = MyObject()
        }
        return share!
    }
    
    func showChatControllerForUser(user: User, navigationController: UINavigationController) {
        let chatLogController = ChatLogController()
        chatLogController.user = user
        navigationController.pushViewController(chatLogController, animated: true)
    }

    func showChatControllerForGroups(group: Group, navigationController: UINavigationController) {
        let chatLogController = ChatLogController()
        chatLogController.group = group
        navigationController.pushViewController(chatLogController, animated: true)
    }

    func estimateFrameForText(text: String, width: CGFloat, height: CGFloat) -> CGRect {
        let size = CGSize(width: width, height: height)
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
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
