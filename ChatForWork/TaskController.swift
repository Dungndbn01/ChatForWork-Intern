//
//  TaskController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/19/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import LBTAComponents

class TaskController: UIViewController {
    lazy var customNavBar = UIView()
    lazy var addTaskButton = UIButton()
    lazy var navTitleView = UILabel()

    let taskSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["My Tasks", "Requested Task"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.blue
        sc.selectedSegmentIndex = 0
        sc.layer.cornerRadius = 5
        sc.layer.masksToBounds = true
        sc.backgroundColor = .white
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    var taskSegmentContainer = UIView()
    var taskView = UIView()
    let myTask = MyTaskController()
    let requestedTask = RequestedTaskController()
    
    var delegate: MainViewController?
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        addMyTaskView()
//        setupNavBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = false
    }
    
    private func setupNavBar() {
        let moreImage = UIImage(named: "PlusICO")?.withRenderingMode(.alwaysTemplate)
        var moreBarButtonItem = UIBarButtonItem()
            moreBarButtonItem = UIBarButtonItem(image: moreImage, style: .plain, target: self, action: #selector(handleAddTask))
        moreBarButtonItem.tintColor = UIColor.white
        navigationItem.rightBarButtonItem = moreBarButtonItem
        navigationItem.rightBarButtonItem?.tintColor = UIColor.white
    }
    
    @objc private func handleLoginRegisterChange() {
        if taskSegmentedControl.selectedSegmentIndex == 0 {
            addMyTaskView()
        } else {
            addResquestedTaskView()
        }
    }
    
    func addMyTaskView() {
        taskView.addSubview(myTask.view)
        self.addChildViewController(myTask)
        myTask.didMove(toParentViewController: self)
        
        requestedTask.view.removeFromSuperview()
        requestedTask.removeFromParentViewController()
    }
    
    func addResquestedTaskView() {
        taskView.addSubview(requestedTask.view)
        self.addChildViewController(requestedTask)
        requestedTask.didMove(toParentViewController: self)
        
        myTask.view.removeFromSuperview()
        myTask.removeFromParentViewController()
    }
    
    func addRequestedTaskView() {
        
    }
    
    func handleAddTask() {
        let addTask = AddTaskController()
        let navController = UINavigationController(rootViewController: addTask)
        self.present(navController, animated: true, completion: nil)
        }
    
    func setupViews(){
        customNavBar.backgroundColor = UIColor(r: 5, g: 5, b: 5)
        
        navTitleView.text = "Task"
        navTitleView.font = UIFont.boldSystemFont(ofSize: 16)
        navTitleView.textColor = .white
        navTitleView.textAlignment = .center
        
        addTaskButton.setImage(UIImage(named: "PlusICO")?.withRenderingMode(.alwaysTemplate), for: .normal)
        addTaskButton.tintColor = .white
        addTaskButton.addTarget(self, action: #selector(handleAddTask), for: .touchUpInside)

        taskSegmentContainer.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        taskSegmentContainer.translatesAutoresizingMaskIntoConstraints = false
        taskView.backgroundColor = .white
        
        view.addSubview(customNavBar)
        view.addSubview(navTitleView)
        view.addSubview(addTaskButton)
        view.addSubview(taskSegmentContainer)
        taskSegmentContainer.addSubview(taskSegmentedControl)
        view.addSubview(taskView)
        
        customNavBar.anchor(self.view.topAnchor, left: self.view.leftAnchor, bottom: nil, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 64)
        navTitleView.anchor(nil, left: self.view.centerXAnchor, bottom: customNavBar.bottomAnchor, right: nil, topConstant: 0, leftConstant: -50, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 40)
        addTaskButton.anchor(nil, left: nil, bottom: customNavBar.bottomAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 12, widthConstant: 50, heightConstant: 40)
        
        taskSegmentContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 64).isActive = true
        taskSegmentContainer.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        taskSegmentContainer.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        taskSegmentContainer.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        taskSegmentedControl.topAnchor.constraint(equalTo: taskSegmentContainer.topAnchor, constant: 5).isActive = true
        taskSegmentedControl.bottomAnchor.constraint(equalTo: taskSegmentContainer.bottomAnchor, constant: -5).isActive = true
        taskSegmentedControl.leftAnchor.constraint(equalTo: taskSegmentContainer.leftAnchor, constant: 40).isActive = true
        taskSegmentedControl.rightAnchor.constraint(equalTo: taskSegmentContainer.rightAnchor, constant: -40).isActive = true
        
        taskView.anchor(taskSegmentContainer.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 50, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
    }
    
}

