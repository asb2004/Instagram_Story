//
//  StoryPageViewController.swift
//  Task_12
//
//  Created by DREAMWORLD on 24/05/24.
//

import UIKit

protocol ScrollUserStory {
    func scrollToNextUser()
    func scrollToPreviousUser()
}

class StoryPageViewController: UIPageViewController {
    
    var userDetails = [UserDetails]()
    var userIndex: Int!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.delegate = self
        self.dataSource = self
        
        if let vc = getViewController(at: userIndex) {
            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

extension StoryPageViewController: UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    func getViewController(at index: Int) -> StoryPlayViewController? {
        
        if index < 0 || index > userDetails.count - 1 {
            return nil
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "StoryPlayViewController") as! StoryPlayViewController
        vc.user = userDetails[index]
        vc.index = index
        vc.delegate = self
        return vc
        
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? StoryPlayViewController else {
            return nil
        }
        let nextIndex = currentVC.index + 1
        return getViewController(at: nextIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? StoryPlayViewController else {
            return nil
        }
        let previousIndex = currentVC.index - 1
        return getViewController(at: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed, let currentVC = pageViewController.viewControllers?.first as? StoryPlayViewController {
            userIndex = currentVC.index
        }
    }
    
}

extension StoryPageViewController: ScrollUserStory {
    
    func scrollToNextUser() {
        let nextIndex = userIndex + 1
        if nextIndex >= userDetails.count {
            dismiss(animated: true, completion: nil)
            return
        }
        
        if let vc = getViewController(at: nextIndex) {
            self.setViewControllers([vc], direction: .forward, animated: true, completion: nil)
            userIndex = nextIndex
        }
    }
    
    func scrollToPreviousUser() {
        let previousIndex = userIndex - 1
        if previousIndex < 0 {
            dismiss(animated: true, completion: nil)
            return
        }
        
        if let vc = getViewController(at: previousIndex) {
            self.setViewControllers([vc], direction: .reverse, animated: true, completion: nil)
            userIndex = previousIndex
        }
    }

}
