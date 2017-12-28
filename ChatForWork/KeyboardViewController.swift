//
//  KeyboardViewController.swift
//  ChatForWork
//
//  Created by DevOminext on 12/26/17.
//  Copyright © 2017 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

class KeyboardViewController: UIInputViewController {
    let rows = [["q", "w", "e", "r", "t", "y", "u", "i", "o", "p"],
                ["a", "s", "d", "f", "g", "h", "j", "k", "l"],
                ["z", "x", "c", "v", "b", "n", "m"]]
    let topPadding: CGFloat = 12
    let keyHeight: CGFloat = 40
    let keyWidth: CGFloat = 26
    let keySpacing: CGFloat = 6
    let rowSpacing: CGFloat = 15
    let shiftWidth: CGFloat = 40
    let shiftHeight: CGFloat = 40
    let spaceWidth: CGFloat = 210
    let spaceHeight: CGFloat = 40
    let nextWidth: CGFloat = 50
    
    var buttons: Array<UIButton> = []
    var shiftKey: UIButton?
    var deleteKey: UIButton?
    var spaceKey: UIButton?
    var nextKeyboardButton: KeyButton?
    var returnButton: KeyButton?
    
    var shiftPosArr = [0]
    var numCharacters = 0
    var spacePressed = false
    var spaceTimer: Timer?
    
    override func updateViewConstraints() {
        super.updateViewConstraints()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //        self.view.backgroundColor = UIColor(red: 241.0/255, green: 235.0/255, blue: 221.0/255, alpha: 0)
        self.view.alpha = 0
        
        let border = UIView(frame: CGRect(x:CGFloat(0.0), y:CGFloat(0.0), width:self.view.frame.size.width, height:CGFloat(0.5)))
        border.autoresizingMask = UIViewAutoresizing.flexibleWidth
        border.backgroundColor = UIColor(red: 210.0/255, green: 205.0/255, blue: 193.0/255, alpha: 1)
        self.view.addSubview(border)
        
        let thirdRowTopPadding: CGFloat = topPadding + (keyHeight + rowSpacing) * 2
        shiftKey = KeyButton(frame: CGRect(x: 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight))
        shiftKey!.addTarget(self, action: #selector(KeyboardViewController.shiftKeyPressed(_:)), for: .touchUpInside)
        shiftKey!.isSelected = true
        shiftKey!.setImage(UIImage(named: "shift.png"), for:UIControlState())
        shiftKey!.setImage(UIImage(named: "shift-selected.png"), for:.selected)
        self.view.addSubview(shiftKey!)
        
        deleteKey = KeyButton(frame: CGRect(x:320 - shiftWidth - 2.0, y: thirdRowTopPadding, width:shiftWidth, height:shiftHeight))
        deleteKey!.addTarget(self, action: #selector(KeyboardViewController.deleteKeyPressed(_:)), for: .touchUpInside)
        deleteKey!.setImage(UIImage(named: "delete.png"), for:UIControlState())
        deleteKey!.setImage(UIImage(named: "delete-selected.png"), for:.highlighted)
        self.view.addSubview(deleteKey!)
        
        let bottomRowTopPadding = topPadding + keyHeight * 3 + rowSpacing * 2 + 10
        spaceKey = KeyButton(frame: CGRect(x:(320.0 - spaceWidth) / 2, y: bottomRowTopPadding, width:spaceWidth, height:spaceHeight))
        spaceKey!.setTitle(" ", for: UIControlState())
        spaceKey!.addTarget(self, action: #selector(KeyboardViewController.keyPressed(_:)), for: .touchUpInside)
        self.view.addSubview(spaceKey!)
        
        nextKeyboardButton = KeyButton(frame:CGRect(x:2, y: bottomRowTopPadding, width:nextWidth, height:spaceHeight))
        nextKeyboardButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        nextKeyboardButton!.setTitle(NSLocalizedString("Next", comment: "Title for 'Next Keyboard' button"), for: UIControlState())
        nextKeyboardButton!.addTarget(self, action: #selector(UIInputViewController.advanceToNextInputMode), for: .touchUpInside)
        view.addSubview(self.nextKeyboardButton!)
        
        returnButton = KeyButton(frame: CGRect(x:320 - nextWidth - 2, y: bottomRowTopPadding, width:nextWidth, height:spaceHeight))
        returnButton!.setTitle(NSLocalizedString("Ret", comment: "Title for 'Return Key' button"), for:UIControlState())
        returnButton!.titleLabel?.font = UIFont(name: "HelveticaNeue-Light", size:18)
        returnButton!.addTarget(self, action: #selector(KeyboardViewController.returnKeyPressed(_:)), for: .touchUpInside)
        self.view.addSubview(returnButton!)
        
        var y: CGFloat = topPadding
        let width = UIScreen.main.applicationFrame.size.width
        for row in rows {
            var x: CGFloat = ceil((width - (CGFloat(row.count) - 1) * (keySpacing + keyWidth) - keyWidth) / 2.0)
            for label in row {
                let button = KeyButton(frame: CGRect(x: x, y: y, width: keyWidth, height: keyHeight))
                button.setTitle(label.uppercased(), for: UIControlState())
                button.addTarget(self, action: #selector(KeyboardViewController.keyPressed(_:)), for: UIControlEvents.touchUpInside)
                //button.autoresizingMask = .FlexibleWidth | .FlexibleLeftMargin | .FlexibleRightMargin
                button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 1, bottom: 0, right: 0)
                
                self.view.addSubview(button)
                buttons.append(button)
                x += keyWidth + keySpacing
            }
            
            y += keyHeight + rowSpacing
        }
    }
    
    @objc func returnKeyPressed(_ sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        proxy.insertText("\n")
        numCharacters += 1
        shiftPosArr[shiftPosArr.count - 1] += 1
        if shiftKey!.isSelected {
            shiftPosArr.append(0)
            setShiftValue(true)
        }
        
        spacePressed = false
    }
    
    @objc func deleteKeyPressed(_ sender: UIButton) {
        if numCharacters > 0 {
            let proxy = self.textDocumentProxy as UITextDocumentProxy
            proxy.deleteBackward()
            numCharacters -= 1
            var charactersSinceShift = shiftPosArr[shiftPosArr.count - 1]
            if charactersSinceShift > 0 {
                charactersSinceShift -= 1
            }
            
            setShiftValue(charactersSinceShift == 0)
            if charactersSinceShift == 0 && shiftPosArr.count > 1 {
                shiftPosArr.removeLast()
            }
            else {
                shiftPosArr[shiftPosArr.count - 1] = charactersSinceShift
            }
        }
        
        spacePressed = false
    }
    
    @objc func shiftKeyPressed(_ sender: UIButton) {
        setShiftValue(!shiftKey!.isSelected)
        if shiftKey!.isSelected {
            shiftPosArr.append(0)
        }
        else if shiftPosArr[shiftPosArr.count - 1] == 0 {
            shiftPosArr.removeLast()
        }
        
        spacePressed = false
    }
    
    @objc func keyPressed(_ sender: UIButton) {
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        if spacePressed && sender.titleLabel?.text == " " {
            proxy.deleteBackward()
            proxy.insertText(". ")
            spacePressed = false
        }
        else {
            proxy.insertText(sender.titleLabel?.text ?? "")
            spacePressed = sender.titleLabel?.text == " "
            if spacePressed {
                spaceTimer?.invalidate()
                spaceTimer = Timer.scheduledTimer(timeInterval: 1,
                                                  target: self,
                                                  selector: #selector(KeyboardViewController.spaceTimeout),
                                                  userInfo: nil,
                                                  repeats: false)
            }
        }
        
        numCharacters += 1
        shiftPosArr[shiftPosArr.count - 1] += 1
        if (shiftKey!.isSelected) {
            self.setShiftValue(false)
        }
    }
    
    @objc func spaceTimeout() {
        spaceTimer = nil
        spacePressed = false
    }
    
    func setShiftValue(_ shiftVal: Bool) {
        if shiftKey?.isSelected != shiftVal {
            shiftKey!.isSelected = shiftVal
            for button in buttons {
                var text = button.titleLabel?.text
                if shiftKey!.isSelected {
                    text = text?.uppercased()
                } else {
                    text = text?.lowercased()
                }
                
                button.setTitle(text, for: UIControlState())
                button.titleLabel?.sizeToFit()
            }
        }
    }
    
    override func textWillChange(_ textInput: UITextInput?) {
        // The app is about to change the document's contents. Perform any preparation here.
    }
    
    override func textDidChange(_ textInput: UITextInput?) {
        // The app has just changed the document's contents, the document context has been updated.
        
        var textColor: UIColor
        let proxy = self.textDocumentProxy as UITextDocumentProxy
        if proxy.keyboardAppearance == UIKeyboardAppearance.dark {
            textColor = UIColor.white
        } else {
            textColor = UIColor.black
        }
        //self.nextKeyboardButton.setTitleColor(textColor, forState: .Normal)
    }
    
}

class KeyButton: UIButton {
    override init(frame: CGRect)  {
        super.init(frame: frame)
        
        self.titleLabel?.font = UIFont(name: "HelveticaNeue", size: 22.0)
        self.titleLabel?.textAlignment = .center
        self.setTitleColor(UIColor(white: 68.0/255, alpha: 1), for: UIControlState())
        self.titleLabel?.sizeToFit()
        
        self.layer.borderWidth = 0.5
        self.layer.borderColor = UIColor(red: 216.0/255, green: 211.0/255, blue: 199.0/255, alpha: 1).cgColor
        self.layer.cornerRadius = 3
        
        self.backgroundColor = UIColor(red: 248.0/255, green: 242.0/255, blue: 227.0/255, alpha: 1)
        self.contentVerticalAlignment = .center
        self.contentHorizontalAlignment = .center
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(Coder) has not been implemented")
    }
}


