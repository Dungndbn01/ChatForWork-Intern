//
//  CollectionViewController.swift
//  emoji
//
//  Created by Nguyen Dinh Dung on 2017/12/24.
//  Copyright © 2017年 Nguyen Dinh Dung. All rights reserved.
//

import UIKit

//private let reuseIdentifier = "Cell"

class EmojiController: UICollectionViewController {
    let tf = UITextField()
    var delegate: EmojiControllerDelegate?
    
    var emojiList: [[String]] = []
    let sectionTitle: [String] = ["Emoticons", "Dingbats", "Transport and map symbols", "Enclosed Characters"]
    let cellId = "cellId"
    
    override func viewDidLoad() {
        super .viewDidLoad()
        self.view.backgroundColor = .white
        tf.placeholder = "Enter here..."
        tf.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tf)
        
        tf.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tf.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tf.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tf.heightAnchor.constraint(equalToConstant: 50).isActive = true
        self.collectionView?.backgroundColor = .white
        
        collectionView?.topAnchor.constraint(equalTo: tf.bottomAnchor).isActive = true
        collectionView?.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView?.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        collectionView?.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        self.collectionView?.register(DragCell.self, forCellWithReuseIdentifier: cellId)
        fetchEmojis()
    }
    func fetchEmojis(){
        
        
        
        let emojiRanges = [
            0x1F601...0x1F64F,
            0x2702...0x27B0,
            0x1F680...0x1F6C0,
            0x1F170...0x1F251
        ]
        
        
        for range in emojiRanges {
            var array: [String] = []
            for i in range {
                if let unicodeScalar = UnicodeScalar(i){
                    array.append(String(describing: unicodeScalar))
                }
            }
            
            emojiList.append(array)
        }
        
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! DragCell
        cell.imageView.image = emojiList[indexPath.section][indexPath.item].image()
        return cell
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return emojiList[section].count
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return emojiList.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.addEmojiText(emoji: emojiList[indexPath.section][indexPath.item])
    }
}

protocol EmojiControllerDelegate: class {
    func addEmojiText(emoji: String)
}

extension ChatLogController: EmojiControllerDelegate {
    func addEmojiText(emoji: String) {
        inputTextView.text = inputTextView.text! + emoji
    }
}

extension String {
    
    func image() -> UIImage? {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, false, 0);
        UIColor.clear.set()
        
        let stringBounds = (self as NSString).size(attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 50)])
        let originX = (size.width - stringBounds.width)/2
        let originY = (size.height - stringBounds.height)/2
        print(stringBounds)
        let rect = CGRect(origin: CGPoint(x: originX, y: originY), size: size)
        UIRectFill(rect)
        (self as NSString).draw(in: rect, withAttributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 50)])
        
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    } }

class DragCell: UICollectionViewCell {
    var imageView = UIImageView()
    func setupViews() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

