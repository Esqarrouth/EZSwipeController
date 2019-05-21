//
//  MySwipe.swift
//  EZSwipeController
//
//  Created by Goktug Yilmaz on 14/11/15.
//  Copyright © 2015 Goktug Yilmaz. All rights reserved.
//

import UIKit
// import EZSwipeController // if using Cocoapods
class MySwipeVC: EZSwipeController {
    override func setupView() {
        datasource = self
//        navigationBarShouldBeOnBottom = true
//        navigationBarShouldNotExist = true
//        cancelStandardButtonEvents = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
    }
}

extension MySwipeVC: EZSwipeControllerDataSource {
    
    func viewControllerData() -> [UIViewController] {
        let redVC = UIViewController()
        redVC.view.backgroundColor = UIColor.red
        let char = UIImageView(x: 50, y: 100, imageName: "char", scaleToWidth: 300)
        redVC.view.addSubview(char)
        
        let testButton = UIButton(frame: CGRect(x: 250, y: 30, width: 100, height: 100))
        testButton.setTitle("Click for last page", for: UIControl.State())
        testButton.setTitleColor(UIColor.red, for: UIControl.State())
        testButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        testButton.backgroundColor = UIColor.green
        testButton.addTarget(self, action: #selector(MySwipeVC.moveToEnd), for: UIControl.Event.touchUpInside)
        redVC.view.addSubview(testButton)
      
        let label = UILabel()
        label.text = "Test view bottom"
        label.sizeToFit()
        label.center = CGPoint(
          x: redVC.view.bounds.width / 2,
          y: redVC.view.bounds.height - label.frame.size.height
        )
        label.autoresizingMask = [
          .flexibleTopMargin,
          .flexibleLeftMargin,
          .flexibleRightMargin
        ]
        redVC.view.addSubview(label)
        
        let blueVC = UIViewController()
        blueVC.view.backgroundColor = UIColor.blue
        let squir = UIImageView(x: 50, y: 100, imageName: "squir", scaleToWidth: 300)
        blueVC.view.addSubview(squir)

        let greenVC = UIViewController()
        greenVC.view.backgroundColor = UIColor.green
        let bulb = UIImageView(x: 50, y: 125, imageName: "bulb", scaleToWidth: 300)
        greenVC.view.addSubview(bulb)

        return [redVC, blueVC, greenVC]
    }
    
    func navigationBarDataForPageIndex(_ index: Int) -> UINavigationBar {
        var title = ""
        if index == 0 {
            title = "Charmander"
        } else if index == 1 {
            title = "Squirtle"
        } else if index == 2 {
            title = "Bulbasaur"
        }

        let navigationBar = UINavigationBar()
        navigationBar.barStyle = UIBarStyle.default
        navigationBar.barTintColor = UIColor(red: 231/255, green: 231/255, blue: 231/255, alpha: 1)
        navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black]
        
        let navigationItem = UINavigationItem(title: title)
        navigationItem.hidesBackButton = true
        
        if index == 0 {
            var sImage = UIImage(named: "squir")!
            sImage = scaleTo(image: sImage, w: 22, h: 22)
            let rightButtonItem = UIBarButtonItem(image: sImage, style: .plain, target: self, action: nil)
            rightButtonItem.tintColor = UIColor.blue
            
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 1 {
            var cImage = UIImage(named: "char")!
            cImage = scaleTo(image: cImage, w: 22, h: 22)
            let leftButtonItem = UIBarButtonItem(image: cImage, style: .plain, target: self, action: nil)
            leftButtonItem.tintColor = UIColor.red
            
            var bImage = UIImage(named: "bulb")!
            bImage = scaleTo(image: bImage, w: 22, h: 22)
            let rightButtonItem = UIBarButtonItem(image: bImage, style: .plain, target: self, action: nil)
            rightButtonItem.tintColor = UIColor.green
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = rightButtonItem
        } else if index == 2 {
            var sImage = UIImage(named: "squir")!
            sImage = scaleTo(image: sImage, w: 22, h: 22)
            let leftButtonItem = UIBarButtonItem(image: sImage, style: .plain, target: self, action: nil)
            leftButtonItem.tintColor = UIColor.blue
            
            navigationItem.leftBarButtonItem = leftButtonItem
            navigationItem.rightBarButtonItem = nil
        }
        navigationBar.pushItem(navigationItem, animated: false)
        return navigationBar
    }
    
    func changedToPageIndex(_ index: Int) {
        print("Page has changed to: \(index)")
    }
    
    @objc func moveToEnd() {
        self.moveToPage(2, animated: true)
    }
    
    func alert(title: String?, message: String, action: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}

private func scaleTo(image: UIImage, w: CGFloat, h: CGFloat) -> UIImage {
    let newSize = CGSize(width: w, height: h)
    UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
    image.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
    let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return newImage
}


private extension UIImageView {
    
    /// EZSwiftExtensions
    convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, imageName: String) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        image = UIImage(named: imageName)
    }
    
    /// EZSwiftExtensions
    convenience init(x: CGFloat, y: CGFloat, imageName: String, scaleToWidth: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: 0, height: 0))
        image = UIImage(named: imageName)
        scaleImageFrameToWidth(width: scaleToWidth)
    }
    
    /// EZSwiftExtensions
    convenience init(x: CGFloat, y: CGFloat, w: CGFloat, h: CGFloat, image: UIImage) {
        self.init(frame: CGRect(x: x, y: y, width: w, height: h))
        self.image = image
    }
    
    /// EZSwiftExtensions
    convenience init(x: CGFloat, y: CGFloat, image: UIImage, scaleToWidth: CGFloat) {
        self.init(frame: CGRect(x: x, y: y, width: 0, height: 0))
        self.image = image
        scaleImageFrameToWidth(width: scaleToWidth)
    }
    
    /// EZSwiftExtensions, scales this ImageView size to fit the given width
    func scaleImageFrameToWidth(width: CGFloat) {
        let widthRatio = image!.size.width / width
        let newWidth = image!.size.width / widthRatio
        let newHeigth = image!.size.height / widthRatio
        frame = CGRect(x: frame.origin.x, y: frame.origin.y, width: newWidth, height: newHeigth)
    }
    
}
