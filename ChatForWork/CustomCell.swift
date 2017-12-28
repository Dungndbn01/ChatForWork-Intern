//
//  CustomCell.swift
//  ChatForWork
//
//  Created by DevOminext on 12/22/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    override var isHighlighted: Bool {
        didSet {
            self.backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
        }
    }
    
    lazy var detailTitle = UILabel()
    lazy var detailName = UILabel()
    lazy var separatorLine = UIView()
    func setupViews() {
        detailTitle.textAlignment = .left
        detailTitle = detailTitle.setUpLabel(labelText: "", textColor: .darkGray, size: 12)
        
        detailName.textAlignment = .left
        detailName = detailName.setUpLabel(labelText: "", textColor: .darkText, size: 16)
        
        separatorLine.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        addSubview(detailTitle)
        addSubview(detailName)
        addSubview(separatorLine)
        
        detailTitle.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 8, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 12)
        detailName.anchor(self.centerYAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: -4, leftConstant: 16, bottomConstant: 0, rightConstant: 16, widthConstant: 0, heightConstant: 18)
        separatorLine.anchor(nil, left: self.leftAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 16, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

