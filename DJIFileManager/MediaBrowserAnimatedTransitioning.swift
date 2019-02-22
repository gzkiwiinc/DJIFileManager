//
//  MediaFileAnimatedTransitioning.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import UIKit

class MediaFileAnimatedTransitioning: NSObject, UIViewControllerAnimatedTransitioning {
    var dismissing: Bool = false
    var startingView: UIView?
    var endingView: UIView?
    var scaleAnimatedImage: UIImage?
    
    var shouldPerformScaleAnimation: Bool {
        get {
            return self.startingView != nil && self.endingView != nil
        }
    }
}


// MARK:- UIViewControllerAnimatedTransitioning

extension MediaFileAnimatedTransitioning {
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if shouldPerformScaleAnimation {
            scaleAnimationWithTransitionContext(transitionContext)
        } else {
            fadeAnimationWithTransitionContext(transitionContext)
        }
    }
}


// MARK:- Function

extension MediaFileAnimatedTransitioning {
    func scaleAnimationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVC = transitionContext.viewController(forKey: .from),
            let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let isPresentation = (toVC.presentingViewController == fromVC)
        if !isPresentation, let fromView = transitionContext.view(forKey: .from) {
            fromView.alpha = 0
        }
        
        guard let startingView = startingView,
            let endingView = endingView,
            let scaleAnimatedImage = scaleAnimatedImage else { return }
        
        let containerView = transitionContext.containerView
        
        let backgoundView = UIView()
        backgoundView.backgroundColor = djiFileManagerTheme.backgroundColor
        backgoundView.frame = containerView.frame
        
        if isPresentation, let presentedView = transitionContext.view(forKey: .to) {
            containerView.addSubview(backgoundView)
            containerView.addSubview(presentedView)
            presentedView.isHidden = true
        }
        
        let scaleAnimatedImageView = UIImageView()
        scaleAnimatedImageView.contentMode = .scaleAspectFill
        scaleAnimatedImageView.clipsToBounds = true
        
        var startingFrame = startingView.convert(startingView.bounds, to: containerView)
        startingFrame.size.height = min(startingFrame.height, UIScreen.main.bounds.height)
        
        var endingFrame = endingView.convert(endingView.bounds, to: containerView)
        endingFrame.size.height = min(endingFrame.height, UIScreen.main.bounds.height)
        
        if isLongImage(scaleAnimatedImage) {
            let imageSize = scaleAnimatedImage.size
            let cropHeight = min(UIScreen.main.bounds.height, endingFrame.height) / endingFrame.width * imageSize.width
            let cropRect = CGRect(x: 0, y: 0, width: imageSize.width, height: cropHeight)
            if let imageRef: CGImage = scaleAnimatedImage.cgImage?.cropping(to: cropRect) {
                let cropped: UIImage = UIImage(cgImage: imageRef)
                scaleAnimatedImageView.image = cropped
            }
        } else {
            scaleAnimatedImageView.image = scaleAnimatedImage
        }

        scaleAnimatedImageView.frame = startingFrame
        containerView.addSubview(scaleAnimatedImageView)
        
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            delay: 0.0,
            usingSpringWithDamping: 1.0,
            initialSpringVelocity: 0,
            animations: {
                scaleAnimatedImageView.frame = endingFrame
            },
            completion: { result in
                transitionContext.view(forKey: .to)?.isHidden = false
                scaleAnimatedImageView.removeFromSuperview()
                backgoundView.removeFromSuperview()
                self.completeTransitionWithTransitionContext(transitionContext)
            })
    }
    
    func fadeAnimationWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        let fadeView = dismissing ? transitionContext.view(forKey: UITransitionContextViewKey.from) : transitionContext.view(forKey: UITransitionContextViewKey.to)
        let beginningAlpha: CGFloat = dismissing ? 1.0 : 0.0
        let endingAlpha: CGFloat = dismissing ? 0.0 : 1.0
        fadeView?.alpha = beginningAlpha
        UIView.animate(
            withDuration: transitionDuration(using: transitionContext),
            animations: {
                fadeView?.alpha = endingAlpha
            },
            completion: { finished in
                if !self.shouldPerformScaleAnimation {
                    self.completeTransitionWithTransitionContext(transitionContext)
                }
            })
    }
    
    func completeTransitionWithTransitionContext(_ transitionContext: UIViewControllerContextTransitioning) {
        if transitionContext.isInteractive {
            if transitionContext.transitionWasCancelled {
                transitionContext.cancelInteractiveTransition()
            } else {
                transitionContext.finishInteractiveTransition()
            }
        }
        transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
    }
    
    private func isLongImage(_ image: UIImage) -> Bool {
        let imageSize = image.size
        let imageActualHeight = UIScreen.main.bounds.width * CGFloat(imageSize.height) / CGFloat(imageSize.width)
        return imageActualHeight >= UIScreen.main.bounds.height
    }
}
