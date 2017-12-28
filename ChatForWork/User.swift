//
//  User.swift
//  ChatApp
//
//  Created by Nguyen Dinh Dung on 2017/10/24.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var checkOnline: String?
    var isTypingCheck: String?
    var lastTimeLoggin: NSNumber?
    var lastTimeLogout: NSNumber?
    var chattingWith: String?

    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var backgroundImageUrl: String?
    var chatId: String?
    var organization: String?
    var team: String?
    var jobTitle: String?
    var address: String?
    var url: String?
    var workPhone: String?
    var userExtension: String?
    var mobile: String?
}
