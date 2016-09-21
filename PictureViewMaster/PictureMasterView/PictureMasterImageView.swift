//
//  PictureMasterImageView.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 4/6/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

@objc public protocol PictureMasterImageViewDelegate: NSObjectProtocol {
    func pictureMasterImageViewDidReceiveTap (_ pictureMasterImageView: PictureMasterImageView)
}

open class PictureMasterImageView: UIImageView {
    open weak var delegate: PictureMasterImageViewDelegate!
    
    public override init (frame: CGRect) {
        super.init(frame: frame)
        self.addTapGesture()
    }
    
    public convenience init () {
        self.init(frame:CGRect.zero)
        self.addTapGesture()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addTapGesture()
    }
    
    public convenience init (frame: CGRect, andDelegate delegate: PictureMasterImageViewDelegate) {
        self.init(frame: frame)
        self.delegate = delegate
        self.addTapGesture()
    }
    
    public override init (image: UIImage?) {
        super.init(image: image)
        self.addTapGesture()
    }
    
    public convenience init (image: UIImage?, andDelegate delegate: PictureMasterImageViewDelegate) {
        self.init(image: image)
        self.delegate = delegate
        self.addTapGesture()
    }
    
    fileprivate func addTapGesture (){
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
    }
    
    func tapGesture (_ gesture: UITapGestureRecognizer) {
        self.delegate.pictureMasterImageViewDidReceiveTap(self)
    }
}
