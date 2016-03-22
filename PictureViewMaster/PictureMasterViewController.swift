//
//  PictureMasterViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 3/21/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

class PictureMasterViewController: UIViewController {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var imageViewFrame : CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGestureRecognizers()
    }
    
    private func originalImageViewFitFrameForImage(image: UIImage) -> CGRect {
        let screenSize = UIScreen.mainScreen().bounds
        var frame = CGRect()
        
        let heightRatio = image.size.height / image.size.width
        let widthRatio = image.size.width / image.size.height
        let screenRatio = screenSize.width / screenSize.height
        
        if image.size.height > image.size.width && widthRatio < screenRatio {
            
            frame.size.height = screenSize.height
            frame.size.width = frame.height * widthRatio
        }else {
            frame.size.width = screenSize.width
            frame.size.height = frame.width * heightRatio
        }
        
        frame.origin.x = (screenSize.size.width / 2) - (frame.size.width / 2)
        frame.origin.y = (screenSize.size.height / 2) - (frame.size.height / 2)
        
        return frame
    }
    
    private func addGestureRecognizers() {
        self.imageView.userInteractionEnabled = true
        self.imageView.multipleTouchEnabled = true
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinchGesture:"))
        self.imageView.addGestureRecognizer(pinchRecognizer)
        
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: Selector("dragGesture:"))
        self.imageView.addGestureRecognizer(dragRecognizer)
        
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: Selector("rotateGesture:"))
        self.imageView.addGestureRecognizer(rotateRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapBackgroundGesture:"))
        self.backgroundView.addGestureRecognizer(tapRecognizer)
    }
    
    func pinchGesture(gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale)
        gesture.scale = 1
    }
    
    func dragGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == .Ended {
            self.centerImage(self.imageView)
            return
        }
        
        guard let view = gesture.view else { return }
    
        let translation = gesture.translationInView(self.view)
        view.center = CGPoint(x:view.center.x + translation.x,
            y:view.center.y + translation.y)
        gesture.setTranslation(CGPointZero, inView: self.view)
    }
    
    func rotateGesture(gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        
        view.transform = CGAffineTransformRotate(view.transform, gesture.rotation)
        gesture.rotation = 0
    }
    
    func tapBackgroundGesture(gesture: UITapGestureRecognizer) {
        self.resetImageFrameAndRotation(self.imageView)
    }
    
    private func centerImage(imageView: UIImageView) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            let screenSize = UIScreen.mainScreen().bounds
            let centerX = (screenSize.size.width / 2) - (imageView.frame.width / 2)
            let centerY = (screenSize.size.height / 2) - (imageView.frame.height / 2)
            
            let frame = CGRect(x: centerX, y: centerY, width: imageView.frame.width, height: imageView.frame.height)
            imageView.frame = frame
            }, completion:nil)
    }
    
    private func resetImageFrameAndRotation(imageView: UIImageView) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            let rotation = (atan2(imageView.transform.b, imageView.transform.a))
            imageView.transform = CGAffineTransformRotate(imageView.transform, -rotation)
            imageView.frame = self.originalImageViewFitFrameForImage(imageView.image!)
            }, completion:nil)
    }
}
