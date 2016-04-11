## PictureViewMaster
Interactive image projector.


```
This library supports Swift 2.3
Swift 2.3 is currently in branch master.
```

### Abstract

This is a library that provides an UIImageView subclass with the capability of enlarge its image so the user can rotate it, drag it and zoom it.

### How to use it?

Instead of using regulars UIImageView objects use PictureMasterImageView. They'll automatically add a gesture recognizer that will let its delegate knows when the user tap on it. Then, on the delegate callback, implement the PictureMasterViewController by instantiating an object and giving it the UIImage and/or the gestures you want to support (All of them by default.). It will bring a view inside your current view with the large image and all the gesture recognizers, plus the dismissing functionality.
NOTE: PictureMasterImageView is not actually required. You can just pass the UIImage you want to the `PictureMasterViewController` and it will also works. The UIImage subclass is just to have a nice and easy way to have clickable and enlargable UIImageViews. 

### Install

Drag this files to your project :
`PictureMasterViewController.xib`
`PictureMasterViewController.swift`
`PictureMasterImageView.swift`
and you are ready to go. 
Or you can use CocoaPods:

```
pod 'PictureMasterView'

```

Then import the library:

```
import PictureMasterView
```

#### USAGE:

```swift
//Create an PictureMasterImageView object and assign its delegate
let sampleImage : PictureMasterImageView = PictureMasterImageView(image: UIImage(named:"sampleImage"), andDelegate:self)
//Or just add it on the interface builder, add a reference and assign a the delegate
self.ibSampleImage.delegate = self

//Then conform the the PictureMasterImageViewDelegate
func pictureMasterImageViewDidReceiveTap (pictureMasterImageView: PictureMasterImageView) {
let masterViewController: PictureMasterViewController = PictureMasterViewController(nibName: "PictureMasterViewController", bundle: nil)
// Initialized with custom gestures
masterViewController.showImage(pictureMasterImageView.image!, inViewController:self, withGestures: [.Rotate, .Zoom, .Drag])
// Initialized with all gestures enabled
masterViewController.showImage(pictureMasterImageView.image!, inViewController:self)
}

And that's it. PictureMasterView will take care of showing himself and dismissing himself too because we all are lazy programers and... 
<a href="http://25.media.tumblr.com/tumblr_m5kz3dTnPI1rp5220o1_500">
![2015-03-17(http://25.media.tumblr.com/tumblr_m5kz3dTnPI1rp5220o1_500.jpg)
</a>


### Contact Us
For **questions** or **general comments** regarding the use of this library, please use our public
[hipchat room](http://inaka.net/hipchat).

If you find any **bugs** or have a **problem** while using this library, please [open an issue](https://github.com/inaka/PictureViewMaster-iOS/issues/new) in this repo (or a pull request :)).

And you can check all of our open-source projects at [inaka.github.io](http://inaka.github.io)
