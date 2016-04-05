//
//  PictureMasterViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 3/21/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

class PictureMasterViewController: UIViewController , UIGestureRecognizerDelegate {
    enum IncomeDirection {
        case In
        case Up
        case Down
        case Right
        case Left
    }
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    var imageViewFrame : CGRect!
    var offDirection : IncomeDirection = .In
    
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
            self.moveInView(gesture.view!, fromDirection: self.isViewOutOfBounds(gesture.view!),
                            withCompletion:nil)
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
    
    private func isViewOutOfBounds(view: UIView) -> IncomeDirection{
        let screenSize = UIScreen.mainScreen().bounds
        
        if (view.frame.origin.x + view.frame.width) < screenSize.width && (view.frame.width >= screenSize.width) && self.offDirection != .Right {
            self.offDirection = .Right
            return .Right
        }else if (view.frame.origin.x > 0) && (view.frame.width >= screenSize.width) && self.offDirection != .Left {
            self.offDirection = .Left
            return .Left
        }else if (view.frame.origin.y + view.frame.height) < screenSize.height && (view.frame.height >= screenSize.height) && self.offDirection != .Down {
            self.offDirection = .Down
            return .Down
        }else if (view.frame.origin.y > 0) && (view.frame.height >= screenSize.height) && self.offDirection != .Up {
            self.offDirection = .Up
            return .Up
        }else {
            self.offDirection = .In
            return .In
        }
    }
    
    private func moveInView(view: UIView, fromDirection direction: IncomeDirection, withCompletion completion: ((Bool) -> Void)?) {
        var viewX : CGFloat
        var viewY : CGFloat
        
        let screenSize = UIScreen.mainScreen().bounds
        
        switch direction {
        case .Down:
            viewX = view.frame.origin.x
            viewY = screenSize.size.height - view.frame.height
        case .Up:
            viewX = view.frame.origin.x
            viewY = 0
        case .Right:
            viewX = screenSize.size.width - view.frame.width
            viewY = view.frame.origin.y
        case .Left:
            viewX = 0
            viewY = view.frame.origin.y
        default:
            view.userInteractionEnabled = true
            return
        }
        
        UIView.animateWithDuration(0.1, delay: 0.0, options: .CurveEaseOut, animations: {
            let frame = CGRect(x: viewX, y: viewY, width: view.frame.width, height: view.frame.height)
            view.frame = frame
            }, completion: { finished in
                self.moveInView(view, fromDirection: self.isViewOutOfBounds(view), withCompletion: completion)
        })
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
