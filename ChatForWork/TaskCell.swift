//
//  TaskCell.swift
//  ChatForWork
//
//  Created by DevOminext on 12/20/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    lazy var leftView = UIView()
    lazy var taskContentView = UITextView()
    lazy var dueDateLabel = UILabel()
    
    func setupViews() {
       leftView.layer.cornerRadius = 5
        leftView.layer.borderWidth = 1
        leftView.layer.borderColor = UIColor(r: 235, g: 235, b: 235).cgColor
        
        contentView.addSubview(leftView)
        contentView.addSubview(taskContentView)
        contentView.addSubview(dueDateLabel)
        
        leftView.anchor(contentView.topAnchor, left: contentView.leftAnchor, bottom: nil, right: nil, topConstant: 12, leftConstant: 12, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        taskContentView.anchor(contentView.topAnchor, left: leftView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 16, leftConstant: 12, bottomConstant: 30, rightConstant: 12, widthConstant: 0, heightConstant: 0)
        dueDateLabel.anchor(nil, left: leftView.leftAnchor, bottom: contentView.bottomAnchor, right: contentView.rightAnchor, topConstant: 0, leftConstant: 12, bottomConstant: 8, rightConstant: 12, widthConstant: 0, heightConstant: 16)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }

    required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
    }

}


