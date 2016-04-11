//
//  SampleViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 4/7/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController, PictureMasterImageViewDelegate {
    @IBOutlet weak var sampleImage1: PictureMasterImageView!
    @IBOutlet weak var sampleImage2: PictureMasterImageView!
    @IBOutlet weak var sampleImage3: PictureMasterImageView!
    @IBOutlet weak var sampleImage4: PictureMasterImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sampleImage1.delegate = self
        sampleImage2.delegate = self
        sampleImage3.delegate = self
        sampleImage4.delegate = self
    }
    func pictureMasterImageViewDidReceiveTap (pictureMasterImageView: PictureMasterImageView) {
        let masterViewController: PictureMasterViewController = PictureMasterViewController(nibName: "PictureMasterViewController", bundle: nil)
        // Initialized with custom gestures enabled
        //        masterViewController.showImage(pictureMasterImageView.image!, inViewController:self, withGestures: [.Rotate, .Zoom, .Drag])
        // Initialized with all gestures enabled
        masterViewController.showImage(pictureMasterImageView.image!, inViewController:self)
    }
}
