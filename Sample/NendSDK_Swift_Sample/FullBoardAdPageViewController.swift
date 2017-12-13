//
//  FullBoardAdPageViewController.swift
//  NendSDK_Sample
//
//  Copyright © 2017年 F@N Communications. All rights reserved.
//

import UIKit
import NendAd

class FullBoardAdPageViewController: UIViewController, UIPageViewControllerDataSource, NADFullBoardViewDelegate {
    
    private var contentViewControllers = [UIViewController]()
    private var pageViewController: UIPageViewController!
    private var loader = NADFullBoardLoader(spotId: "485504", apiKey: "30fda4b3386e793a14b27bedb4dcd29f03d638e5")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        self.pageViewController.dataSource = self
        self.pageViewController.view.frame = self.view.frame
        self.view.addSubview(self.pageViewController.view)
        
        for i in 0 ..< 5 {
            if let content = self.storyboard?.instantiateViewController(withIdentifier: "FullBoardPageContent") as? FullBoardAdContentViewController {
                content.number = String(i + 1)
                self.contentViewControllers.append(content)
            }
        }
        if 0 < self.contentViewControllers.count {
            self.pageViewController.setViewControllers([self.contentViewControllers[0]], direction: .forward, animated: false, completion: nil)
        }

        let group = DispatchGroup()
        for i in 0 ..< 2 {
            group.enter()
            let insertIndex = 0 == i ? 2 : 4
            self.loader!.loadAd { [weak self] (ad: NADFullBoard?, error: NADFullBoardLoaderError) in
                guard let `self` = self else {
                    return
                }
                if let fullBoardAd = ad {
                    let adViewController = fullBoardAd.fullBoardAdViewController()
                    adViewController?.delegate = self
                    self.contentViewControllers.insert(adViewController!, at: insertIndex)
                }
                group.leave();
            }
            group.notify(queue: DispatchQueue.main) {
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }
        }
    }
    
    // MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = self.contentViewControllers.index(of: viewController), index > 0 else {
            return nil
        }
        return self.contentViewControllers[index - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = self.contentViewControllers.index(of: viewController), index < self.contentViewControllers.count - 1 else {
            return nil
        }
        return self.contentViewControllers[index + 1]
    }
    
    // MARK: - NADFullBoardViewDelegate
    
    func nadFullBoardDidClickAd(_ ad: NADFullBoard!) {
        print(#function)

    }
}
