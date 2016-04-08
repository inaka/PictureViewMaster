//
//  SampleViewController.swift
//  PictureViewMaster
//
//  Created by El gera de la gente on 4/7/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import UIKit

class SampleViewController: UIViewController, MasterViewDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func showImageInMasterView(image: UIImage) {
        let masterViewController: PictureMasterViewController = PictureMasterViewController(nibName: "PictureMasterViewController", bundle: nil)
        masterViewController.showImage(image, inViewController:self)
    }
}
