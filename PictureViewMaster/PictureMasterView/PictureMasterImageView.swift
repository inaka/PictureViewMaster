//
//  PictureMasterImageView.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 4/6/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

@objc protocol PictureMasterImageViewDelegate: NSObjectProtocol {
    func pictureMasterImageViewDidReceiveTap (pictureMasterImageView: PictureMasterImageView)
}

class PictureMasterImageView: UIImageView {
    weak var delegate: PictureMasterImageViewDelegate!
    
    override init (frame: CGRect) {
        super.init(frame: frame)
        self.addTapGesture()
    }
    
    convenience init () {
        self.init(frame:CGRect.zero)
        self.addTapGesture()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTapGesture()
    }
    
    convenience init (frame: CGRect, andDelegate delegate: PictureMasterImageViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
        self.addTapGesture()
    }
    
    override init (image: UIImage?) {
        super.init(image: image)
        self.addTapGesture()
    }
    
    convenience init (image: UIImage?, andDelegate delegate: PictureMasterImageViewDelegate) {
        self.init(image: image)
        self.delegate = delegate
        self.addTapGesture()
    }
    
    private func addTapGesture (){
        self.userInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
    }
    
    func tapGesture (gesture: UITapGestureRecognizer) {
        self.delegate.pictureMasterImageViewDidReceiveTap(self)
    
    }
}
