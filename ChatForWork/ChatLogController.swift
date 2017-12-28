//
//  ChatLogController.swift
//  ChatForWork
//
//  Created by Nguyen Dinh Dung on 2017/12/17.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit
import Firebase

class ChatLogController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate, UIImagePickerControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PartnerControllerDelegate {
    let keyboardView = KeyboardViewController()
    let emoji = EmojiController(collectionViewLayout: UICollectionViewFlowLayout())
    let partner = PartnerController()
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    var partnerNameArr = [String]()
    lazy var partnerNameColView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    weak var backButton = UIButton()
    weak var chatInformationButton = UIButton()
    
    lazy var inputContainerView = UIView()
    lazy var inputTextView = UITextField()
    lazy var showOptionsButton = UIButton()
    lazy var showEmojiButton = UIButton()
    lazy var separatorLine = UIView()
    lazy var showKeyBoardButton = UIButton()
    lazy var showToUserButton = UIButton()
    lazy var sendButton = UIButton()
    var inputContainerBottomAnchor: NSLayoutConstraint?
    var inputContainerViewHeightAnchor: NSLayoutConstraint?
    
    lazy var optionsContainer = UIView()
    lazy var upperStackView = UIStackView()
    lazy var bottomStackView = UIStackView()
    lazy var taskButton = UIButton()
    lazy var cameraButton = UIButton()
    lazy var cameraRollButton = UIButton()
    lazy var voiceMessagesButton = UIButton()
    lazy var locationButton = UIButton()
    lazy var chooseFileButton = UIButton()
    
    var chatLogTableView = UITableView(frame: .zero, style: .grouped)
    let cellId = "cellId"
    let headerId = "headerId"
    var messages = [Message]()
    var messagesInSection = [[Message]]()
    var dateStrings = [String]()
    var textForHeaders = [String]()
    
    var dictionary1 = [String: AnyObject]()
    var dictionary2 = [String: String]()
    var dictionary3 = [String: String]()
    
    var user: User? {
        didSet {
            let uid = Auth.auth().currentUser?.uid
            navigationItem.title = user?.name
            if (user?.id == uid) {
                navigationItem.title = "My Chat"
            }
        }
    }
    var group: Group? {
        didSet {
            navigationItem.title = group?.name
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        emoji.delegate = self
        partner.delegate = self
        partnerNameColView.dataSource = self
        partnerNameColView.delegate = self
        partnerNameColView.register(PartnerNameCell.self, forCellWithReuseIdentifier: "colCellId")

        setupButtonsProperties()
        
        observeUserMessage()
        inputTextView.delegate = self
        chatLogTableView.dataSource = self
        chatLogTableView.delegate = self
        chatLogTableView.separatorStyle = UITableViewCellSeparatorStyle.none
        chatLogTableView.backgroundColor = UIColor.white
        chatLogTableView.contentInset = UIEdgeInsetsMake(8, 0, 8, 0)
        chatLogTableView.tableFooterView = UIView(frame: CGRect.zero)
        chatLogTableView.sectionFooterHeight = 0.0
        chatLogTableView.register(ChatMessageCell.self, forCellReuseIdentifier: cellId)
        chatLogTableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: headerId)
        MyObject.instance().userId = user?.id ?? ""
        MyObject.instance().groupId = group?.id ?? ""
        
        hideKeyboardWhenTappedAround(bool: true)
        setupNavBar()
        setupInputContainerView()
        setupInputTextView()
        setupKeyBoardObservers()
        self.view.backgroundColor = .clear
    }
    
//    func deleteCell(array: [String], colView: UICollectionView, item: Int) {
//        array.remove(at: item)
//        colView.reloadData()
//    }
    
    func appendElement(element: String) {
        partnerNameArr.append(element)
        partnerNameColView.reloadData()
        
//        partnerNameColView.removeFromSuperview()
//        view.addSubview(partnerNameColView)
//        partnerNameColView.anchor(nil, left: view.leftAnchor, bottom: inputContainerView.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: CGFloat(partnerNameArr.count * 30))
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return partnerNameArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colCellId", for: indexPath) as! PartnerNameCell
        cell.delegate = self
        cell.item = indexPath.item
        cell.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        cell.backgroundColor = UIColor(r:235, g: 235,b:235)
        let name = partnerNameArr[indexPath.item]
        cell.partnerNameLabel.text = "TO: \(name)"
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 200, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func setupInputTextView() {
        inputContainerView.addSubview(inputTextView)
        inputContainerView.addSubview(showEmojiButton)
        inputContainerView.addSubview(showOptionsButton)

        inputTextView.anchor(inputContainerView.topAnchor, left: inputContainerView.leftAnchor, bottom: nil, right: inputContainerView.rightAnchor, topConstant: 8, leftConstant: 12, bottomConstant: 0, rightConstant: 112, widthConstant: 0, heightConstant: 34)
        showEmojiButton.anchor(inputContainerView.topAnchor, left: nil, bottom: nil, right: inputContainerView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
        showOptionsButton.anchor(inputContainerView.topAnchor, left: nil, bottom: nil, right: showEmojiButton.leftAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 50, heightConstant: 50)
    }
    
    func setupInputContainerView() {
        inputContainerView.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        inputContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        separatorLine.backgroundColor = UIColor(r: 235, g: 235, b: 235)
        
        inputTextView.layer.cornerRadius = 8
        inputTextView.layer.masksToBounds = true
        inputTextView.backgroundColor = .green
        inputTextView.font = UIFont.systemFont(ofSize: 14)
        inputTextView.placeholder = "Type a message..."
        
        showEmojiButton.setImage(UIImage(named: "SmileICO")?.withRenderingMode(.alwaysTemplate), for: .normal)
        showEmojiButton.tintColor = .black
        showEmojiButton.addTarget(self, action: #selector(handleShowEmoji), for: .touchUpInside)
        showOptionsButton.setImage(UIImage(named: "AddICO")?.withRenderingMode(.alwaysTemplate), for: .normal)
        showOptionsButton.tintColor = .black
        showOptionsButton.addTarget(self, action: #selector(handleShowOptions), for: .touchUpInside)
        
        showKeyBoardButton.setTitle("Aa", for: .normal)
        showKeyBoardButton.setTitleColor(.black, for: .normal)
        showKeyBoardButton.addTarget(self, action: #selector(handleShowKeyboard), for: .touchUpInside)
        
        showToUserButton.setTitle("TO", for: .normal)
        showToUserButton.setTitleColor(.black, for: .normal)
        showToUserButton.addTarget(self, action: #selector(handleShowToUser), for: .touchUpInside)
                
        sendButton.setTitle("Send", for: .normal)
        sendButton.setTitleColor(.lightGray, for: .normal)
        sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        
        chatLogTableView.isScrollEnabled = true
        partnerNameColView.backgroundColor = .clear
        partnerNameColView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        
        view.addSubview(inputContainerView)
        view.addSubview(separatorLine)
        view.addSubview(chatLogTableView)
        view.addSubview(partnerNameColView)
        
        inputContainerView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        inputContainerView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        inputContainerBottomAnchor = inputContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 50)
        inputContainerBottomAnchor?.isActive = true
        inputContainerViewHeightAnchor = inputContainerView.heightAnchor.constraint(equalToConstant: 100)
        inputContainerViewHeightAnchor?.isActive = true

        separatorLine.anchor(nil, left: self.view.leftAnchor, bottom: inputContainerView.topAnchor, right: self.view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 1)
        chatLogTableView.anchor(view.topAnchor, left: view.leftAnchor, bottom: separatorLine.topAnchor, right: view.rightAnchor, topConstant: 64, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        partnerNameColView.anchor(nil, left: view.leftAnchor, bottom: inputContainerView.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: CGFloat(180))
    }
    
    func handleShowKeyboard() {
        showKeyBoardButton.setTitleColor(.blue, for: .normal)
        showEmojiButton.tintColor = .black
        showToUserButton.setTitleColor(.black, for: .normal)
        showOptionsButton.tintColor = .black
        
        inputTextView.inputView = keyboardView.deleteKey
        inputTextView.becomeFirstResponder()
    }
    
    func handleShowToUser() {
        showKeyBoardButton.setTitleColor(.black, for: .normal)
        showEmojiButton.tintColor = .black
        showToUserButton.setTitleColor(.blue, for: .normal)
        showOptionsButton.tintColor = .black
        
        setupToUsersView()
        emoji.view.removeFromSuperview()
        optionsContainer.removeFromSuperview()
        
        inputTextView.becomeFirstResponder()
        inputTextView.inputView = partner.view
        inputTextView.becomeFirstResponder()

    }
    
    func handleShowEmoji() {
        showKeyBoardButton.setTitleColor(.black, for: .normal)
        showEmojiButton.tintColor = .blue
        showToUserButton.setTitleColor(.black, for: .normal)
        showOptionsButton.tintColor = .black
        
        setupEmojiView()
        partner.view.removeFromSuperview()
        optionsContainer.removeFromSuperview()

        inputTextView.becomeFirstResponder()
        inputTextView.inputView = emoji.view
        inputTextView.becomeFirstResponder()
    }
    
    func handleShowOptions() {
        showKeyBoardButton.setTitleColor(.black, for: .normal)
        showEmojiButton.tintColor = .black
        showToUserButton.setTitleColor(.black, for: .normal)
        showOptionsButton.tintColor = .blue
        
        setupOptionsContainerView()
        emoji.view.removeFromSuperview()
        partner.view.removeFromSuperview()
        
        inputTextView.becomeFirstResponder()
        inputTextView.inputView = optionsContainer
        inputTextView.becomeFirstResponder()
    }
    
    func handleSend() {
//            if let uid = Auth.auth().currentUser?.uid {
//                let typingCheckRef = Database.database().reference(withPath: "user/\(uid)/isTypingCheck")
//                typingCheckRef.setValue("false")
//                observeUserTypingChange(value: 1)
//            }
        
            if inputTextView.text != "" {
                var string: String! = inputTextView.text!
                while string[string.index(before: string.endIndex)] == " " && string != " "{
                    string.remove(at: string.index(before: string.endIndex))
                }
                inputTextView.text = string }
        
            if inputTextView.text != "" && inputTextView.text != " " && inputTextView.textColor != UIColor.lightGray {
                let properties: [String: AnyObject] = ["text": inputTextView.text! as AnyObject]
                let properties2: [String: String] = ["a": "a"]
                var properties3: [String: String] = ["b": "b"]
                for i in 0..<self.partnerNameArr.count {
                    properties3.updateValue(self.partnerNameArr[i], forKey: String(i))
                }

                sendMessageWithProperties(properties: properties, properties2: properties2, properties3: properties3)
                
                inputTextView.text = ""
                inputTextView.placeholder = "Type a message..."
            }
        partnerNameArr = [String]()
        partnerNameColView.reloadData()
        sendButton.setTitleColor(.gray, for: .normal)
    }
    
    func backButtonClick(sender: UIButton) {
        let chatLog = ChatLogController()
        chatLog.removeFromParentViewController()
        MyObject.instance().chattingUser = nil
        MyObject.instance().chattingGroup = nil
        NotificationCenter.default.removeObserver(handleKeyboardWillShow)
        NotificationCenter.default.removeObserver(handleKeyboardWillEnd)
//        MyObject.instance().userId = ""
//        MyObject.instance().groupId = ""

        self.navigationController?.popViewController(animated: true)
    }
    
    func showChatInformation() {
//        self.present(ViewController1(), animated: true, completion: nil)
    }
    
    func setupNavBar() {
        self.navigationItem.hidesBackButton = true
        let leftBarItem = UIBarButtonItem(image: UIImage(named: "backBT")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector (backButtonClick(sender:)))
        navigationItem.leftBarButtonItem = leftBarItem
        navigationItem.leftBarButtonItem?.tintColor = .white
        
        let rightBarItem = UIBarButtonItem(image: UIImage(named: "rsz_threedots")?.withRenderingMode(.alwaysTemplate), style: .plain, target: self, action: #selector (showChatInformation))
        navigationItem.rightBarButtonItem = rightBarItem
        navigationItem.rightBarButtonItem?.tintColor = .white
        
    }
    
    func performZoomInForStartingImageView(startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        startingImageView.isHidden = true
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.blue
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.removeFromSuperview()
            keyWindow.addSubview(blackBackgroundView!)
            keyWindow.addSubview(zoomingImageView)
            
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,options: .curveEaseInOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                let height = (self.startingFrame?.height)! / (self.startingFrame?.width)! * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                zoomingImageView.center = keyWindow.center
            }, completion: nil)
        }
        
    }
    
    func handleZoomOut(tapGesture: UIPanGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            // need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.removeFromSuperview()
            }, completion: { [unowned self] (completion: Bool) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }

}

extension ChatLogController {
//    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        return "Section \(section)"
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: headerId)
        header?.backgroundColor = .clear

        let dateLabel = UILabel()
        dateLabel.backgroundColor = .gray
        dateLabel.textColor = .white
        dateLabel.textAlignment = .center
        dateLabel.layer.cornerRadius = 8
        dateLabel.layer.masksToBounds = true
        dateLabel.text = textForHeaders[section]
        
        header?.addSubview(dateLabel)
        dateLabel.anchor(header?.topAnchor, left: header?.centerXAnchor, bottom: nil, right: nil, topConstant: 10, leftConstant: -50, bottomConstant: 0, rightConstant: 0, widthConstant: 100, heightConstant: 20)
        return header
    }
    
//    func numberOfSections(in tableView: UITableView) -> Int {
//        return textForHeaders.count
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath as IndexPath) as! ChatMessageCell
        cell.message = messages[indexPath.row]
        cell.dateString = dateStrings[indexPath.row]
        if cell.message?.dueDate != nil {
            cell.taskView.isHidden = false
            cell.nameView.isHidden = true
            cell.messageText.isHidden = true
            cell.backgroundColor = UIColor(r: 226, g: 240, b: 205)
        } else if (cell.message?.nameDict?.count)! > Int(2) {
            cell.taskView.isHidden = true
            cell.messageText.isHidden = true
            cell.nameView.isHidden = false
            cell.backgroundColor = .white
            if (cell.message?.nameDict?.count)! > Int(6) {
                cell.backgroundColor = UIColor(r: 226, g: 240, b: 205) }
        } else {
            cell.taskView.isHidden = true
            cell.nameView.isHidden = true
            cell.messageText.isHidden = false
            cell.backgroundColor = .white
        }
        if messages.count == 1 || indexPath.row == 0{
            cell.dateLabel.isHidden = false
        } else {
            if dateStrings[indexPath.row] == dateStrings[indexPath.row - 1] {
                cell.dateLabel.isHidden = true
            } else if dateStrings[indexPath.row] != dateStrings[indexPath.row - 1] {
                cell.dateLabel.isHidden = false
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let width = self.view.frame.width - 88
        let height = self.estimateFrameForText(text: messages[indexPath.row].text!, width: width, height: 1000).height
        if (messages[indexPath.row].urlDict?.count)! > Int(2) {
        let subHeight = (((messages[indexPath.row].urlDict?.count)! - 2) / 8) * 30
        let rowHeight = CGFloat(subHeight) + height + 16 + 117 + 60
            return rowHeight } else if (messages[indexPath.row].nameDict?.count)! > Int(2) {
            let subHeight = ((messages[indexPath.row].nameDict?.count)! - 2) * 30
             let rowHeight = CGFloat(subHeight) + height + 86 + 30
            return rowHeight
        }
        
        return height + 86
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
    }
    
        func estimateFrameForText(text: String, width: CGFloat, height: CGFloat) -> CGRect {
            let size = CGSize(width: width, height: height)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 16)], context: nil)
        }
}

class PartnerNameCell: UICollectionViewCell {
    lazy var partnerNameLabel = UILabel()
    lazy var deleteButton = UIButton()
    var item: Int?
    var arr: [String]?
    var delegate: PartnerNameCellDelegate?
    var colView: UICollectionView?
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        partnerNameLabel.textColor = .blue
        deleteButton.setImage(UIImage(named: "x-button"), for: .normal)
        deleteButton.contentMode = .scaleAspectFill
        deleteButton.addTarget(self, action: #selector(handleDeleteItem), for: .touchUpInside)
        self.addSubview(deleteButton)
        self.addSubview(partnerNameLabel)
        
        deleteButton.anchor(self.topAnchor, left: self.leftAnchor, bottom: self.bottomAnchor, right: nil, topConstant: 0, leftConstant: 8, bottomConstant: 0, rightConstant: 0, widthConstant: 30, heightConstant: 30)
        partnerNameLabel.anchor(self.topAnchor, left: deleteButton.rightAnchor, bottom: self.bottomAnchor, right: self.rightAnchor, topConstant: 0, leftConstant: 4, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
    }
    
    func handleDeleteItem() {
        delegate?.deleteCell(item: item!)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

protocol PartnerNameCellDelegate: class {
    func deleteCell(item: Int)
}

extension ChatLogController: PartnerNameCellDelegate {
    func deleteCell(item: Int) {
        partnerNameArr.remove(at: item)
        partnerNameColView.deleteItems(at: [IndexPath(item: item, section: 0)])
        partnerNameColView.transform = CGAffineTransform(rotationAngle: (180.0 * CGFloat(Double.pi)) / 180.0)
        partnerNameColView.reloadData()
        

    }
}

