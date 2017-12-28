//
//  ViewController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/26/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

protocol DateViewDelegate: class {
    func setDateText(date: String)
}

enum MyTheme {
    case light
    case dark
}

class DateViewController: UIViewController {
    
    var theme = MyTheme.dark
    var date: String!
    var delegate: DateViewDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Due Date"
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor=Style.bgColor
        
        view.addSubview(calenderView)
        
        calenderView.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive=true
        calenderView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -12).isActive=true
        calenderView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 12).isActive=true
        calenderView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10).isActive=true
        
        let rightBarBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(rightBarBtnAction))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
        
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        calenderView.myCollectionView.collectionViewLayout.invalidateLayout()
    }
    
    @objc func rightBarBtnAction(sender: UIBarButtonItem) {
        self.view.backgroundColor=Style.bgColor
        self.popViewController()
    }
    
    func popViewController() {
        date = calenderView.getDate()
        MyObject.instance().dueDateText = date
        delegate?.setDateText(date: date)
        
        self.navigationController?.popViewController(animated: true)
    }
    
    let calenderView: CalenderView = {
        let v=CalenderView(theme: MyTheme.dark)
        v.translatesAutoresizingMaskIntoConstraints=false
        return v
    }()
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
}


