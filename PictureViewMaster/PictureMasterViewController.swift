//
//  PictureMasterViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 3/21/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

class PictureMasterViewController: UIViewController , UIGestureRecognizerDelegate {
    struct OffsetDirection : OptionSetType {
        let rawValue: Int
        
        static let Inside = OffsetDirection(rawValue: 0)
        static let Up = OffsetDirection(rawValue: 1 << 0)
        static let Down = OffsetDirection(rawValue: 1 << 1)
        static let Right = OffsetDirection(rawValue: 1 << 2)
        static let Left = OffsetDirection(rawValue: 1 << 3)
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var imageViewFrame : CGRect!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.addGestureRecognizers()
    }
    
    private func originalImageViewFitFrameForImage(imageView: UIImageView) -> CGRect {
        let image = imageView.image!
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

        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
        tapRecognizer.numberOfTapsRequired = 2
        self.imageView.addGestureRecognizer(tapRecognizer)
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        self.imageView.addGestureRecognizer(pinchRecognizer)
        pinchRecognizer.delegate = self
        
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragGesture(_:)))
        self.imageView.addGestureRecognizer(dragRecognizer)
        dragRecognizer.delegate = self
        
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
        self.imageView.addGestureRecognizer(rotateRecognizer)
        rotateRecognizer.delegate = self
        
        let tapBackgroundRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundGesture(_:)))
        self.backgroundView.addGestureRecognizer(tapBackgroundRecognizer)
    }
    
    func tapGesture(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        self.resetViewFrameAndRotation(view)
    }
    
    func pinchGesture(gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.hasToEnlargeView(gesture.view!) && gesture.state == .Ended {
            self.enlargeViewToMinimumSize(view)
            return
        }
        
        view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale)
        gesture.scale = 1
    }
    
    func dragGesture(gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.hasToEnlargeView(gesture.view!) && gesture.state == .Ended {
            self.enlargeViewToMinimumSize(view)
            return
        }
        
        if gesture.state == .Ended {
            gesture.view!.userInteractionEnabled = false
            self.moveInView(gesture.view!, fromDirection: self.offsetDirectionForView(gesture.view!),
                            withCompletion: { finish in
                                gesture.view!.userInteractionEnabled = true
            })
            return
        }
    
        let translation = gesture.translationInView(self.view)
        view.center = CGPoint(x:view.center.x + translation.x,
            y:view.center.y + translation.y)
        gesture.setTranslation(CGPointZero, inView: self.view)
    }
    
    func rotateGesture(gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.hasToEnlargeView(gesture.view!) && gesture.state == .Ended {
            self.enlargeViewToMinimumSize(view)
            return
        }
        
        view.transform = CGAffineTransformRotate(view.transform, gesture.rotation)
        gesture.rotation = 0
    }
    
    func tapBackgroundGesture(gesture: UITapGestureRecognizer) {
        self.resetViewFrameAndRotation(self.imageView)
    }
    
    private func offsetDirectionForView(view: UIView) -> OffsetDirection{
        var multipleDirections: OffsetDirection = OffsetDirection.Inside
        
        let screenSize = UIScreen.mainScreen().bounds
        
        if (view.frame.origin.x + view.frame.width) < screenSize.width && (view.frame.width >= screenSize.width) {
            multipleDirections.insert(.Right)
        }
        if (view.frame.origin.x > 0) && (view.frame.width >= screenSize.width) {
            multipleDirections.insert(.Left)
        }
        if (view.frame.origin.y + view.frame.height) < screenSize.height && (view.frame.height >= screenSize.height) {
            multipleDirections.insert(.Down)
        }
        if (view.frame.origin.y > 0) && (view.frame.height >= screenSize.height) {
            multipleDirections.insert(.Up)
        }
        
        return multipleDirections
    }
    
    private func moveInView(view: UIView, fromDirection offsetDirection: OffsetDirection, withCompletion completion: ((Bool) -> Void)?) {
        if offsetDirection == .Inside {
            completion?(true)
            return
        }
        
        var viewX : CGFloat = view.frame.origin.x
        var viewY : CGFloat = view.frame.origin.y
        
        let screenSize = UIScreen.mainScreen().bounds
        
        if offsetDirection.contains(.Down) {
            viewY = screenSize.size.height - view.frame.height
        }
        if offsetDirection.contains(.Up) {
            viewY = 0
        }
        if offsetDirection.contains(.Right) {
            viewX = screenSize.size.width - view.frame.width
        }
        if offsetDirection.contains(.Left) {
            viewX = 0
        }
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
            let frame = CGRect(x: viewX, y: viewY, width: view.frame.width, height: view.frame.height)
            view.frame = frame
            }, completion: completion)
    }
    
    private func hasToEnlargeView(view: UIView) -> Bool{
        let screenSize = UIScreen.mainScreen().bounds
        let smallerThanScreenWidth = (view.frame.width < screenSize.width)
        
        let smallerThanScreenHeigth = (view.frame.height < screenSize.height)
        
        return smallerThanScreenWidth && smallerThanScreenHeigth
    }
    
    private func enlargeViewToMinimumSize(view: UIView) {
        self.resetViewFrame(view, completion: nil)
    }
    
    private func resetViewFrame(view: UIView, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            view.frame = self.originalImageViewFitFrameForImage(view as! UIImageView)
            }, completion:completion)
    }
    
    private func resetViewRotation(view: UIView, completion: ((Bool) -> Void)?) {
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            let rotation = (atan2(view.transform.b, view.transform.a))
            view.transform = CGAffineTransformRotate(view.transform, -rotation)
            }, completion:completion)
    }
    
    private func resetViewFrameAndRotation(view: UIView) {
        self.resetViewRotation(view, completion: nil)
        self.resetViewFrame(view, completion: nil)
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
