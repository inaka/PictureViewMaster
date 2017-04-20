//
//  PictureMasterImageView.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 4/6/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

@objc public protocol PictureMasterImageViewDelegate: NSObjectProtocol {
    func pictureMasterImageViewDidReceiveTap (pictureMasterImageView: PictureMasterImageView)
}

public class PictureMasterImageView: UIImageView {
    #if TARGET_INTERFACE_BUILDER
    @IBOutlet public weak var delegate: AnyObject?
    #else
    public weak var delegate: PictureMasterImageViewDelegate!
    #endif

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
    
    private func addTapGesture() {
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:))))
    }
    
    func tapGesture(_ gesture: UITapGestureRecognizer) {
        self.delegate.pictureMasterImageViewDidReceiveTap(pictureMasterImageView: self)
    }
}
