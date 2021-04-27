//
//  IntroPageViewController.swift
//  The intro page for the user

import UIKit
import Firebase

class IntroPageViewController: UIPageViewController, UIPageViewControllerDataSource {
    
    lazy var viewControllerList:[UIViewController] = {
        
        // create storyboard object
        let sb = UIStoryboard(name: "Main", bundle: nil)
        
        let vc1 = sb.instantiateViewController(withIdentifier: "BeginPageViewController")
        let vc2 = sb.instantiateViewController(withIdentifier: "CustomizePageViewController")
        let vc3 = sb.instantiateViewController(withIdentifier: "SearchPageViewController")
        let vc4 = sb.instantiateViewController(withIdentifier: "SharePageViewController")
        let vc5 = sb.instantiateViewController(withIdentifier: "StartPageViewController")
        
        return [vc1, vc2, vc3, vc4, vc5]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = self
        
        if let firstViewController = viewControllerList.first {
            self.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }
    
    // get the view controller before the current view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else {
            return nil
        }
        
        let previousIndex = vcIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard viewControllerList.count > previousIndex else {
            return nil
        }
        
        
        return viewControllerList[previousIndex]
    }
    
    // get the view controller that comes after the current view controller
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let vcIndex = viewControllerList.index(of: viewController) else {
            return nil
        }
        
        let nextIndex = vcIndex + 1
        
        guard viewControllerList.count != nextIndex else {
            return nil
        }
        
        guard viewControllerList.count > nextIndex else {
            return nil
        }
        
        return viewControllerList[nextIndex]
    }
    
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        return viewControllerList.count
    }

    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
    
    //TODO: figure out what this code means
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for view in self.view.subviews{
            if view is UIScrollView{
                view.frame =  UIScreen.main.bounds
            } else if view is UIPageControl{
                view.backgroundColor = .clear
            }
        }
    }
    
    @IBAction func unwindToIntro (segue: UIStoryboardSegue) {
    }
    
    

}
