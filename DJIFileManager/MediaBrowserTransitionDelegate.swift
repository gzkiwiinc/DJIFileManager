//
//  MediaFileTransitioningDelegate.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import UIKit

class MediaBrowserTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let interactiveAnimator: MediaInteractiveTransitioning = MediaInteractiveTransitioning()
    let transitionAnimator: MediaFileAnimatedTransitioning = MediaFileAnimatedTransitioning()
    var interactiveDismissal: Bool = false
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = false
        return transitionAnimator
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitionAnimator.dismissing = true
        return transitionAnimator
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return nil
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        if interactiveDismissal {
            interactiveAnimator.animator = transitionAnimator
            interactiveAnimator.shouldAnimateUsingAnimator = transitionAnimator.endingView != nil
            interactiveAnimator.viewToHideWhenBeginningTransition = transitionAnimator.startingView != nil ? transitionAnimator.endingView : nil
            return interactiveAnimator
        }
        return nil
    }
    
}
