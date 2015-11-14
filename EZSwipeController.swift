//
//  EZSwipeController.swift
//  EZSwipeController
//
//  Created by Goktug Yilmaz on 24/10/15.
//  Copyright © 2015 Goktug Yilmaz. All rights reserved.
//
import UIKit

@objc public protocol EZSwipeControllerDataSource {
    func viewControllerData() -> [UIViewController]
    optional func indexOfStartingPage() -> Int // Defaults is 0
    optional func titlesForPages() -> [String]
    optional func navigationBarDataForPageIndex(index: Int) -> UINavigationBar
    optional func disableSwipingForLeftButtonAtPageIndex(index: Int) -> Bool
    optional func disableSwipingForRightButtonAtPageIndex(index: Int) -> Bool
    optional func clickedLeftButtonFromPageIndex(index: Int)
    optional func clickedRightButtonFromPageIndex(index: Int)
}

public class EZSwipeController: UIViewController {
    
    public struct Constants {
        public static var Orientation: UIInterfaceOrientation {
            get {
                return UIApplication.sharedApplication().statusBarOrientation
            }
        }
        public static var ScreenWidth: CGFloat {
            get {
                if UIInterfaceOrientationIsPortrait(Orientation) {
                    return UIScreen.mainScreen().bounds.size.width
                } else {
                    return UIScreen.mainScreen().bounds.size.height
                }
            }
        }
        public static var ScreenHeight: CGFloat {
            get {
                if UIInterfaceOrientationIsPortrait(Orientation) {
                    return UIScreen.mainScreen().bounds.size.height
                } else {
                    return UIScreen.mainScreen().bounds.size.width
                }
            }
        }
        public static var StatusBarHeight: CGFloat {
            get {
                return UIApplication.sharedApplication().statusBarFrame.height
            }
        }
        public static var ScreenHeightWithoutStatusBar: CGFloat {
            get {
                if UIInterfaceOrientationIsPortrait(Orientation) {
                    return UIScreen.mainScreen().bounds.size.height - StatusBarHeight
                } else {
                    return UIScreen.mainScreen().bounds.size.width - StatusBarHeight
                }
            }
        }
        public static let navigationBarHeight: CGFloat = 44
        public static let lightGrayColor = UIColor(red: 248, green: 248, blue: 248, alpha: 1)
    }
    
    public var stackNavBars = [UINavigationBar]()
    public var stackVC: [UIViewController]!
    public var stackPageVC: [UIViewController]!
    public var stackStartLocation: Int!
    
    public var bottomNavigationHeight: CGFloat = 44
    public var pageViewController: UIPageViewController!
    public var titleButton: UIButton?
    public var currentStackVC: UIViewController!
    public var datasource: EZSwipeControllerDataSource?
    
    public var navigationBarShouldBeOnBottom = false
    
    public init() {
        super.init(nibName: nil, bundle: nil)
        setupView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupDefaultNavigationBars(pageTitles: [String]) {
        var navBars = [UINavigationBar]()
        for index in 0..<pageTitles.count {
            let navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: Constants.navigationBarHeight))
            navigationBar.barStyle = UIBarStyle.Default
            navigationBar.barTintColor = Constants.lightGrayColor
            
            let navigationItem = UINavigationItem(title: pageTitles[index])
            navigationItem.hidesBackButton = true
            navigationItem.leftBarButtonItem = nil
            navigationItem.rightBarButtonItem = nil
            
            navigationBar.pushNavigationItem(navigationItem, animated: false)
            navBars.append(navigationBar)
        }
        stackNavBars = navBars
    }
    
    private func setupNavigationBar() {
        guard stackNavBars.isEmpty else {
            return
        }
        guard let _ = datasource?.navigationBarDataForPageIndex?(0) else {
            if let titles = datasource?.titlesForPages?() {
                setupDefaultNavigationBars(titles)
            }
            return
        }
        
        for index in 0..<stackVC.count {
            let navigationBar = datasource?.navigationBarDataForPageIndex?(index)
            
            if let nav = navigationBar {
                if navigationBarShouldBeOnBottom {
                    nav.frame = CGRect(x: 0, y: Constants.ScreenHeightWithoutStatusBar - Constants.navigationBarHeight, width: Constants.ScreenWidth, height: Constants.navigationBarHeight)
                } else {
                    nav.frame = CGRect(x: 0, y: 0, width: Constants.ScreenWidth, height: Constants.navigationBarHeight)
                }
                for item in nav.items! {
                    if let leftButton = item.leftBarButtonItem {
                        leftButton.target = self
                        leftButton.action = "clickedLeftButton"
                    }
                    if let rightButton = item.rightBarButtonItem {
                        rightButton.target = self
                        rightButton.action = "clickedRightButton"
                    }
                }
                stackNavBars.append(navigationBar!)
            }
        }
    }
    
    private func setupViewControllers() {
        stackPageVC = [UIViewController]()
        for index in 0..<stackVC.count {
            let pageVC = UIViewController()
            if !navigationBarShouldBeOnBottom {
                stackVC[index].view.frame.origin.y += Constants.navigationBarHeight
            }
            pageVC.addChildViewController(stackVC[index])
            pageVC.view.addSubview(stackVC[index].view)
            stackVC[index].didMoveToParentViewController(pageVC)
            if !stackNavBars.isEmpty {
                pageVC.view.addSubview(stackNavBars[index])
            }
            stackPageVC.append(pageVC)
        }
        currentStackVC = stackPageVC[stackStartLocation]
    }
    
    private func setupPageViewController() {
        pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([stackPageVC[stackStartLocation]], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
        pageViewController.view.frame = CGRect(x: 0, y: Constants.StatusBarHeight, width: Constants.ScreenWidth, height: Constants.ScreenHeightWithoutStatusBar)
        pageViewController.view.backgroundColor = UIColor.clearColor()
        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMoveToParentViewController(self)
    }
    
    public func setupView() {
        
    }
    
    override public func loadView() {
        super.loadView()
        stackVC = datasource?.viewControllerData()
        stackStartLocation = datasource?.indexOfStartingPage?() ?? 0
        guard stackVC != nil else {
            print("Problem: EZSwipeController needs ViewController Data, please implement EZSwipeControllerDataSource")
            return
        }
        setupNavigationBar()
        setupViewControllers()
        setupPageViewController()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc private func clickedLeftButton() {
        let currentIndex = stackPageVC.indexOf(currentStackVC)!
        datasource?.clickedLeftButtonFromPageIndex?(currentIndex)
        
        let shouldDisableSwipe = datasource?.disableSwipingForLeftButtonAtPageIndex?(currentIndex) ?? false
        if shouldDisableSwipe {
            return
        }
        
        if currentStackVC == stackPageVC.first {
            return
        }
        currentStackVC = stackPageVC[currentIndex - 1]
        pageViewController.setViewControllers([currentStackVC], direction: UIPageViewControllerNavigationDirection.Reverse, animated: true, completion: nil)
    }
    
    @objc private func clickedRightButton() {
        let currentIndex = stackPageVC.indexOf(currentStackVC)!
        datasource?.clickedRightButtonFromPageIndex?(currentIndex)
        
        let shouldDisableSwipe = datasource?.disableSwipingForRightButtonAtPageIndex?(currentIndex) ?? false
        if shouldDisableSwipe {
            return
        }
        
        if currentStackVC == stackPageVC.last {
            return
        }
        currentStackVC = stackPageVC[currentIndex + 1]
        pageViewController.setViewControllers([currentStackVC], direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
    }
    
}

extension EZSwipeController: UIPageViewControllerDataSource {
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        if viewController == stackPageVC.first {
            return nil
        }
        return stackPageVC[stackPageVC.indexOf(viewController)! - 1]
    }
    
    public func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        if viewController == stackPageVC.last {
            return nil
        }
        return stackPageVC[stackPageVC.indexOf(viewController)! + 1]
    }
    
}

extension EZSwipeController: UIPageViewControllerDelegate {
    
    public func pageViewController(pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if !completed {
            return
        }
        currentStackVC = stackPageVC[stackPageVC.indexOf(pageViewController.viewControllers!.first!)!]
    }
    
}

