//
//  ScalableImageView.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import UIKit

class ScalableImageView: UIScrollView {

    lazy private(set) var imageView = UIImageView()
    
    var image: UIImage? {
        didSet {
            updateLayout()
            imageView.image = image
        }
    }
    
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapGestureRecognizer))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    
    // MARK: - Initialize
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        minimumZoomScale = 1
        maximumZoomScale = 2
        
        addSubview(imageView)
        addGestureRecognizer(doubleTapGestureRecognizer)
        delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLayout), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}


// MARK: - Function

extension ScalableImageView {
    @objc func updateLayout() {
        let isLandScape = UIScreen.main.bounds.width > UIScreen.main.bounds.height
        guard let imageSize = image?.size else { return }
        var imageViewWidth: CGFloat = 0.0
        var imageViewHeight: CGFloat = 0.0
        if isLandScape {
            imageViewHeight = UIScreen.main.bounds.height
            imageViewWidth = ceil(imageViewHeight * imageSize.width / imageSize.height)
        } else {
            imageViewWidth = UIScreen.main.bounds.width
            imageViewHeight = ceil(imageViewWidth * imageSize.height / imageSize.width)
        }
        contentSize = CGSize(width: imageViewWidth, height: imageViewHeight)
        let frame = CGRect(x: (UIScreen.main.bounds.width - imageViewWidth) / 2.0,
                           y: (UIScreen.main.bounds.height - imageViewHeight) / 2.0,
                           width: imageViewWidth, height: imageViewHeight)
        imageView.frame = frame
    }
    
    @objc private func handleDoubleTapGestureRecognizer(_ gesture: UITapGestureRecognizer) {
        guard imageView.image != nil else { return }
        if zoomScale <= 1 {
            let x = gesture.location(in: self).x + contentOffset.x
            let y = gesture.location(in: self).y + contentOffset.y
            let zoomRect = CGRect(x: x, y: y, width: 0, height: 0)
            zoom(to: zoomRect, animated: true)
        } else {
            setZoomScale(1, animated: true)
        }
    }
    
    private func getActualCenter() -> CGPoint {
        let offsetX = bounds.width > contentSize.width ?
            (bounds.width - contentSize.width) * 0.5 : 0.0
        let offsetY = bounds.height > contentSize.height ?
            (bounds.height - contentSize.height) * 0.5 : 0.0
        let actualCenter = CGPoint(x: contentSize.width * 0.5 + offsetX,
                                   y: contentSize.height * 0.5 + offsetY)
        return actualCenter
    }
}

// MARK: - UIScrollViewDelegate

extension ScalableImageView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        imageView.center = getActualCenter()
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ScalableImageView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 针对 长图 滑动到底部和顶部的处理
        guard otherGestureRecognizer.isMember(of: UIPanGestureRecognizer.self),
            let panGesture = otherGestureRecognizer as? UIPanGestureRecognizer else { return false }
        if contentSize.height - contentOffset.y <= frame.height {
            // 滑到图片底部
            let velocity = panGesture.velocity(in: panGesture.view)
            if velocity.y <= 0 {
                return true
            }
        } else if contentOffset.y <= 0 {
            // 滑到图片顶部
            let velocity = panGesture.velocity(in: panGesture.view)
            if velocity.y >= 0 {
                return true
            }
        }
        return false
    }
}
