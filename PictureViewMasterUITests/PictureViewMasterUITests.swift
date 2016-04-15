//
//  PictureViewMasterUITests.swift
//  PictureViewMasterUITests
//
//  Created by El gera de la gente on 3/21/16.
//  Copyright © 2016 Inaka. All rights reserved.
//

import XCTest

class PictureViewMasterUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testPictureMasterViewControllerBeingPresented() {
        
        let app = XCUIApplication()
        sleep(1)
        
        app.images["image1"].tap()
        sleep(1)
        
        let largeImage = app.images["largeImage"]
        XCTAssert(largeImage.exists)
    }
    
    func testPictureMasterViewControllerBeingDismissed() {
        
        let app = XCUIApplication()
        sleep(1)
        
        app.images["image1"].tap()
        sleep(1)
        
        let backgroundView = app.otherElements["background"]
        backgroundView.tap()
        sleep(1)
        
        let largeImage = app.images["largeImage"]
        XCTAssert(!largeImage.exists)
    }
    
    func testPictureMasterViewControllerImageBeingCorrectlyPlacedInView() {
        
        let app = XCUIApplication()
        sleep(1)
       
        app.images["image1"].tap()
        sleep(1)
        
        let largeImage = app.images["largeImage"]
        sleep(1)
        
        let imageFrame = largeImage.frame
        let screenSize = UIScreen.mainScreen().bounds
        let isHorizontallyWellPlaced = (imageFrame.width < screenSize.width) ? false : (imageFrame.width >= screenSize.width) && (imageFrame.origin.x == 0)
        let isVerticallyWellPlaced = (imageFrame.height < screenSize.height) ? false : (imageFrame.height >= screenSize.height) && (imageFrame.origin.y == 0)
        
        XCTAssert(isHorizontallyWellPlaced || isVerticallyWellPlaced)
    }

    func testPictureMasterViewControllerImageFrameBeingResetedCorrectly() {
        
        let app = XCUIApplication()
        sleep(1)
        
        app.images["image1"].tap()
        sleep(1)
        
        let largeImage = app.images["largeImage"]
        
        largeImage.pinchWithScale(0.8, velocity: -10.0)
        sleep(1)
        
        largeImage.tap()
        largeImage.tap()
        sleep(1)
 
        let imageFrame = largeImage.frame
        let screenSize = UIScreen.mainScreen().bounds
        let isHorizontallyWellPlaced = (imageFrame.width < screenSize.width) ? false : (imageFrame.width >= screenSize.width) && (imageFrame.origin.x == 0)
        let isVerticallyWellPlaced = (imageFrame.height < screenSize.height) ? false : (imageFrame.height >= screenSize.height) && (imageFrame.origin.y == 0)
        
        XCTAssert(isHorizontallyWellPlaced || isVerticallyWellPlaced)
    }
    
}
