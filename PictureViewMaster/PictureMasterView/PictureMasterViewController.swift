//
//  PictureMasterViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 3/21/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

open class PictureMasterViewController: UIViewController , UIGestureRecognizerDelegate {
    public struct Gestures : OptionSet {
        public let rawValue: Int
        public init (rawValue: Int){
            self.rawValue = rawValue
        }
        static let none = Gestures(rawValue: 0)
        static let drag = Gestures(rawValue: 1 << 0)
        static let rotate = Gestures(rawValue: 1 << 1)
        static let zoom = Gestures(rawValue: 1 << 2)
        static let doubleTap = Gestures(rawValue: 1 << 3)
        static let backgroundTap = Gestures(rawValue: 1 << 4)
        static let swipeOut = Gestures(rawValue: 1 << 5)
        static let allGestures = Gestures(rawValue: Int.max)
    }
    
    struct OffsetDirection: OptionSet {
        let rawValue: Int
        
        static let inside = OffsetDirection(rawValue: 0)
        static let up = OffsetDirection(rawValue: 1 << 0)
        static let down = OffsetDirection(rawValue: 1 << 1)
        static let right = OffsetDirection(rawValue: 1 << 2)
        static let left = OffsetDirection(rawValue: 1 << 3)
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!

    fileprivate var enabledGestures = Gestures.allGestures
    fileprivate var image: UIImage!
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupImageViewFrameAndImage(self.image)
        self.addGestureRecognizers()
        self.view.backgroundColor = UIColor.clear
        self.view.isOpaque = false
    }
    
    func showImage(_ image: UIImage, inViewController viewController: UIViewController) {
        self.image = image
        viewController.definesPresentationContext = true
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        viewController.present(self, animated: true, completion: nil)
    }
    
    func showImage(_ image: UIImage, inViewController viewController: UIViewController, withGestures gestures: Gestures) {
        self.enabledGestures = gestures
        self.showImage(image, inViewController: viewController)
    }
    
    fileprivate func setupImageViewFrameAndImage(_ image: UIImage) {
        self.imageView.image = image
        self.resetViewFrame(self.imageView, animated: false,
                                       completion: { finished in
                                        if !finished {
                                            self.resetViewFrameAndRotation(self.imageView, animated: false, completion: {finished in if finished {
                                                    print ("finished")
                                                }})
                                        }})
    }
    
    fileprivate func originalImageViewFitFrameForImage(_ image: UIImage) -> CGRect {
        let screenSize = UIScreen.main.bounds
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

    fileprivate func addGestureRecognizers() {
        self.imageView.isUserInteractionEnabled = true
        self.imageView.isMultipleTouchEnabled = true
        
        if self.enabledGestures.contains(.doubleTap) {
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapGesture(_:)))
            tapRecognizer.numberOfTapsRequired = 2
            self.imageView.addGestureRecognizer(tapRecognizer)
        }
        
        if self.enabledGestures.contains(.zoom) {
            let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
            self.imageView.addGestureRecognizer(pinchRecognizer)
            pinchRecognizer.delegate = self
        }
        
        if self.enabledGestures.contains(.drag) {
            let dragRecognizer = UIPanGestureRecognizer(target: self, action: #selector(dragGesture(_:)))
            self.imageView.addGestureRecognizer(dragRecognizer)
            dragRecognizer.delegate = self
        }
        
        if self.enabledGestures.contains(.rotate) {
            let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: #selector(rotateGesture(_:)))
            self.imageView.addGestureRecognizer(rotateRecognizer)
            rotateRecognizer.delegate = self
        }
        if self.enabledGestures.contains(.backgroundTap) {
            let tapBackgroundRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapBackgroundGesture(_:)))
            self.backgroundView.addGestureRecognizer(tapBackgroundRecognizer)
        }
        if self.enabledGestures.contains(.swipeOut) {
            let swipeOutRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipeOutGesture(_:)))
            swipeOutRecognizer.direction = [.right, .left]
            swipeOutRecognizer.numberOfTouchesRequired = 2
            self.imageView.addGestureRecognizer(swipeOutRecognizer)
        }
    }
    
    open func tapGesture(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        self.resetViewFrameAndRotation(view, animated: true, completion: nil)
    }
    
    open func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.hasToEnlargeView(gesture.view!) && gesture.state == .ended {
            self.enlargeViewToMinimumSize(view)
            return
        }
        
        view.transform = view.transform.scaledBy(x: gesture.scale, y: gesture.scale)
        gesture.scale = 1
    }
    
    func dragGesture(_ gesture: UIPanGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.hasToEnlargeView(gesture.view!) && gesture.state == .ended {
            self.enlargeViewToMinimumSize(view)
            return
        }
        
        if gesture.state == .ended {
            gesture.view!.isUserInteractionEnabled = false
            self.moveInView(gesture.view!, fromDirection: self.offsetDirectionForView(gesture.view!),
                            withCompletion: { finish in
                                gesture.view!.isUserInteractionEnabled = true
            })
            return
        }
    
        let translation = gesture.translation(in: self.view)
        view.center = CGPoint(x:view.center.x + translation.x,
            y:view.center.y + translation.y)
        gesture.setTranslation(CGPoint.zero, in: self.view)
    }
    
    func rotateGesture(_ gesture: UIRotationGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.hasToEnlargeView(gesture.view!) && gesture.state == .ended {
            self.enlargeViewToMinimumSize(view)
            return
        }
        
        view.transform = view.transform.rotated(by: gesture.rotation)
        gesture.rotation = 0
    }
    
    func tapBackgroundGesture(_ gesture: UITapGestureRecognizer) {
        self.dismiss(animated: false, completion: nil)
    }

    func swipeOutGesture(_ gesture: UITapGestureRecognizer) {
        guard let view = gesture.view else { return }
        if self.offsetDirectionForView(view) != .inside && gesture.state == .ended {
            self.dismiss(animated: false, completion: nil)
        }
    }
    
    fileprivate func offsetDirectionForView(_ view: UIView) -> OffsetDirection{
        var multipleDirections: OffsetDirection = OffsetDirection.inside
        
        let screenSize = UIScreen.main.bounds
        
        if (view.frame.origin.x + view.frame.width) < screenSize.width && (view.frame.width >= screenSize.width) {
            multipleDirections.insert(.right)
        }
        if (view.frame.origin.x > 0) && (view.frame.width >= screenSize.width) {
            multipleDirections.insert(.left)
        }
        if (view.frame.origin.y + view.frame.height) < screenSize.height && (view.frame.height >= screenSize.height) {
            multipleDirections.insert(.down)
        }
        if (view.frame.origin.y > 0) && (view.frame.height >= screenSize.height) {
            multipleDirections.insert(.up)
        }
        
        return multipleDirections
    }
    
    fileprivate func moveInView(_ view: UIView, fromDirection offsetDirection: OffsetDirection, withCompletion completion: ((Bool) -> Void)?) {
        if offsetDirection == .inside {
            completion?(true)
            return
        }
        
        var viewX : CGFloat = view.frame.origin.x
        var viewY : CGFloat = view.frame.origin.y
        
        let screenSize = UIScreen.main.bounds
        
        if offsetDirection.contains(.down) {
            viewY = screenSize.size.height - view.frame.height
        }
        if offsetDirection.contains(.up) {
            viewY = 0
        }
        if offsetDirection.contains(.right) {
            viewX = screenSize.size.width - view.frame.width
        }
        if offsetDirection.contains(.left) {
            viewX = 0
        }
        
        UIView.animate(withDuration: 0.1, delay: 0.0, options: .curveEaseOut, animations: {
            let frame = CGRect(x: viewX, y: viewY, width: view.frame.width, height: view.frame.height)
            view.frame = frame
            }, completion: completion)
    }
    
    fileprivate func hasToEnlargeView(_ view: UIView) -> Bool{
        let screenSize = UIScreen.main.bounds
        let smallerThanScreenWidth = (view.frame.width < screenSize.width)
        
        let smallerThanScreenHeigth = (view.frame.height < screenSize.height)
        
        return smallerThanScreenWidth && smallerThanScreenHeigth
    }
    
    fileprivate func enlargeViewToMinimumSize(_ view: UIView) {
        self.resetViewFrame(view, animated: true, completion: nil)
    }
    
    fileprivate func resetViewFrame(_ view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            let imageView = view
            view.frame = self.minimumSizeForView(imageView)
            }, completion:completion)
    }
    
    fileprivate func minimumSizeForView(_ view: UIView) -> CGRect {
        let screenSize = UIScreen.main.bounds
        
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
    
    fileprivate func resetViewRotation(_ view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        let duration = animated ? 0.2 : 0.0
        UIView.animate(withDuration: duration, delay: 0.0, options: .curveEaseOut, animations: {
            let rotation = (atan2(view.transform.b, view.transform.a))
            view.transform = view.transform.rotated(by: -rotation)
            }, completion:completion)
    }
    
    fileprivate func resetViewFrameAndRotation(_ view: UIView, animated: Bool, completion: ((Bool) -> Void)?) {
        self.resetViewRotation(view, animated: animated, completion: nil)
        self.resetViewFrame(view, animated: animated, completion: completion)
    }
    
    //MARK: UIGestureRecognizerDelegate
    
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
