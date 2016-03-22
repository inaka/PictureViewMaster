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
        self.imageViewFrame = self.imageView.frame
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    private func addGestureRecognizers (){
        self.imageView.userInteractionEnabled = true
        self.imageView.multipleTouchEnabled = true
        
        let pinchRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinchGesture:"))
        self.imageView.addGestureRecognizer(pinchRecognizer)
        
        let dragRecognizer = UIPanGestureRecognizer(target: self, action: Selector("dragGesture:"))
        self.imageView.addGestureRecognizer(dragRecognizer)
        
        let rotateRecognizer = UIRotationGestureRecognizer(target: self, action: Selector("rotateGesture:"))
        self.imageView.addGestureRecognizer(rotateRecognizer)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapGesture:"))
        self.backgroundView.addGestureRecognizer(tapRecognizer)
    }
    func pinchGesture (gesture : UIPinchGestureRecognizer) {

        if let view = gesture.view {
            view.transform = CGAffineTransformScale(view.transform, gesture.scale, gesture.scale)
            gesture.scale = 1
        }
    }
    
    func dragGesture (gesture : UIPanGestureRecognizer) {
        let translation = gesture.translationInView(self.view)
        if let view = gesture.view {
            view.center = CGPoint(x:view.center.x + translation.x,
                y:view.center.y + translation.y)
        }
        gesture.setTranslation(CGPointZero, inView: self.view)
    }
    
    func rotateGesture (gesture : UIRotationGestureRecognizer) {
        if let view = gesture.view {
            view.transform = CGAffineTransformRotate(view.transform, gesture.rotation)
            gesture.rotation = 0
        }
    }
    
    func tapGesture (gesture : UITapGestureRecognizer){
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, -(atan2(self.imageView.transform.b, self.imageView.transform.a)))
            self.imageView.frame = self.imageViewFrame
            }, completion: { finished in
                
        })
    }
    
    
    private func resetImageViewAngle (){
        UIView.animateWithDuration(0.2, delay: 0.0, options: .CurveEaseOut, animations: {
            self.imageView.frame = self.imageViewFrame
            self.imageView.transform = CGAffineTransformRotate(self.imageView.transform, -(atan2(self.imageView.transform.b, self.imageView.transform.a)))
            }, completion: { finished in
                
        })
    }
}
