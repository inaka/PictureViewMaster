//
//  PictureMasterImageView.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 4/6/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

@objc protocol MasterViewDelegate: NSObjectProtocol {
    func showImageInMasterView (image: UIImage)
}

class PictureMasterImageView: UIImageView {
    weak var delegate: MasterViewDelegate!
    
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
    
    convenience init (frame: CGRect, andDelegate delegate: MasterViewDelegate) {
        self.init(frame: frame)
        self.addTapGesture()
    }
    
    override init (image: UIImage?) {
        super.init(image: image)
        self.addTapGesture()
    }
    
    private func addTapGesture (){
        self.userInteractionEnabled = true
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showImageInMasterView(_:))))
    }
    
    func showImageInMasterView (gesture: UITapGestureRecognizer) {
        self.delegate.showImageInMasterView(self.image!)
    }
}
