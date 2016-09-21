//
//  PictureMasterViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 3/21/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

public class PictureMasterViewController: UIViewController , UIGestureRecognizerDelegate {
    public struct Gestures : OptionSetType {
        public let rawValue: Int
        public init (rawValue: Int){
            self.rawValue = rawValue
        }
        static let None = Gestures(rawValue: 0)
        static let Drag = Gestures(rawValue: 1 << 0)
        static let Rotate = Gestures(rawValue: 1 << 1)
        static let Zoom = Gestures(rawValue: 1 << 2)
        static let DoubleTap = Gestures(rawValue: 1 << 3)
        static let BackgroundTap = Gestures(rawValue: 1 << 4)
        static let SwipeOut = Gestures(rawValue: 1 << 5)
        static let AllGestures = Gestures(rawValue: Int.max)
    }
    
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

    private var enabledGestures = Gestures.AllGestures
    private var image: UIImage!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageViewFrameAndImage(self.image)
        self.addGestureRecognizers()
        self.view.backgroundColor = UIColor.clearColor()
        self.view.opaque = false
    }
    
    func showImage(image: UIImage, inViewController viewController: UIViewController) {
        self.image = image
        viewController.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.OverCurrentContext
        viewController.presentViewController(self, animated: true, completion: nil)
    }
    
    func showImage(image: UIImage, inViewController viewController: UIViewController, withGestures gestures: Gestures) {
        self.enabledGestures = gestures
        self.showImage(image, inViewController: viewController)
    }
    
    private func setupImageViewFrameAndImage(image: UIImage) {
        self.imageView.image = image
        self.resetViewFrame(self.imageView, animated: false,
                                       completion: { finished in
                                        if !finished {
                                            self.resetViewFrameAndRotation(self.imageView, animated: false, completion: {finished in if finished {
                                                    print ("finished")
                                                }})
                                        }})
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
        
        if self.enabledGestures.contains(.DoubleTap) {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
            tapRecognizer.numberOfTapsRequired = 2
            self.imageView.addGestureRecognizer(tapRecognizer)
        }
        
        if self.enabledGestures.contains(.Zoom) {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
            self.imageView.addGestureRecognizer(pinchRecognizer)
            pinchRecognizer.delegate = self
        }
        
        if self.enabledGestures.contains(.Drag) {
            let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragGesture(_:)))
            self.imageView.addGestureRecognizer(dragRecognizer)
            dragRecognizer.delegate = self
        }
        
        if self.enabledGestures.contains(.Rotate) {
            let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
            self.imageView.addGestureRecognizer(rotateRecognizer)
            rotateRecognizer.delegate = self
        }
        if self.enabledGestures.contains(.BackgroundTap) {
            let tapBackgroundRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundGesture(_:)))
            self.backgroundView.addGestureRecognizer(tapBackgroundRecognizer)
        }
        if self.enabledGestures.contains(.SwipeOut) {
            let swipeOutRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeOutGesture(_:)))
            swipeOutRecognizer.direction = [.Right, .Left]
            swipeOutRecognizer.numberOfTouchesRequired = 2
            self.imageView.addGestureRecognizer(swipeOutRecognizer)
        }
    }
    
    public func tapGesture(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        self.resetViewFrameAndRotation(view, animated: true, completion: nil)
    }
    
    public func pinchGesture(gesture: UIPinchGestureRecognizer) {
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
        self.dismissViewControllerAnimated(false, completion: nil)
    }

    func swipeOutGesture(gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.offsetDirectionForView(view) != .Inside && gesture.state == .Ended {
            self.dismissViewControllerAnimated(false, completion: nil)
        }
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
        self.resetViewFrame(view, animated: true, completion: nil)
    }
    
    private func resetViewFrame(view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        let duration = animated ? 0.2 : 0.0
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseOut, animations: {
            let imageView = view
            view.frame = self.minimumSizeForView(imageView)
            }, completion:completion)
    }
    
    private func minimumSizeForView(view: UIView) -> CGRect {
        let screenSize = UIScreen.mainScreen().bounds
        
        let heightRatio = view.frame.size.height / view.frame.size.width
        let widthRatio = view.frame.size.width / view.frame.size.height
        let screenRatio = screenSize.width / screenSize.height
        
        let frameXOrigin = (screenSize.size.width / 2) - (screenSize.width / 2)
        let frameYOrigin = (screenSize.size.height / 2) - (screenSize.height / 2)
        
        if view.frame.size.height > view.frame.size.width && widthRatio < screenRatio {
            return CGRect(x: frameXOrigin, y: frameYOrigin, width: screenSize.height * widthRatio, height: screenSize.height)
        }else {
            return CGRect(x: frameXOrigin, y: frameYOrigin, width: screenSize.width, height: screenSize.width * heightRatio)
        }
    }
    
    private func resetViewRotation(view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        let duration = animated ? 0.2 : 0.0
        UIView.animateWithDuration(duration, delay: 0.0, options: .CurveEaseOut, animations: {
            let rotation = (atan2(view.transform.b, view.transform.a))
            view.transform = CGAffineTransformRotate(view.transform, -rotation)
            }, completion:completion)
    }
    
    private func resetViewFrameAndRotation(view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        self.resetViewRotation(view, animated: animated, completion: nil)
        self.resetViewFrame(view, animated: animated, completion: completion)
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
