//
//  MediaBrowserViewController.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/2.
//

import UIKit
import DJISDK
import PromiseKit

protocol MediaBrowserDelegate: class {
    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, referenceViewForMedia media: MediaFileBrowsable) -> UIView?
    func mediaBrowser(_ mediaBrowser: MediaBrowserViewController, didDeletedMedia media: MediaFileBrowsable, at index: Int)
}

class MediaBrowserViewController: UIViewController {

    weak var delegate: MediaBrowserDelegate?
    
    var overlayView: MediaFileOverlayView?
    var currentMediaFileViewController: MediaFileDetailViewController? {
        return pageViewController.viewControllers?.first as? MediaFileDetailViewController
    }
    var currentMedia: MediaFileBrowsable? {
        return currentMediaFileViewController?.mediaFile
    }
    
    private(set) var pageViewController: UIPageViewController!
    private(set) var dataSource = [MediaFileBrowsable]()
    
    private(set) lazy var singleTapGestureRecognizer: UITapGestureRecognizer = {
        return UITapGestureRecognizer(target: self, action: #selector(handleSingleTapGestureRecognizer))
    }()
    private(set) lazy var panGestureRecognizer: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureRecognizer))
        gesture.maximumNumberOfTouches = 1
        return gesture
    }()
    
    let mediaFileTransitionDelegate = MediaBrowserTransitionDelegate()
    
    public init(mediaFiles: [MediaFileBrowsable], initialMedia: MediaFileBrowsable? = nil, referenceView: UIView? = nil) {
        dataSource = mediaFiles
        super.init(nibName: nil, bundle: nil)
        initialSetup(with: initialMedia, referenceView: referenceView)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        pageViewController.view.backgroundColor = UIColor.clear

        pageViewController.view.addGestureRecognizer(panGestureRecognizer)
        pageViewController.view.addGestureRecognizer(singleTapGestureRecognizer)
        
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override public func dismiss(animated flag: Bool, completion: (() -> Void)?) {
        if presentedViewController != nil {
            super.dismiss(animated: flag, completion: completion)
            return
        }
        let currentPreviewImage = currentMediaFileViewController?.scalableImageView.imageView.image
        let startingView = currentMediaFileViewController?.scalableImageView.imageView
        mediaFileTransitionDelegate.transitionAnimator.startingView = startingView
        mediaFileTransitionDelegate.transitionAnimator.scaleAnimatedImage = currentPreviewImage
        if let referenceMedia = currentMedia {
            mediaFileTransitionDelegate.transitionAnimator.endingView = delegate?.mediaBrowser(self, referenceViewForMedia: referenceMedia)
        } else {
            mediaFileTransitionDelegate.transitionAnimator.endingView = nil
        }
        
        let isOverlayViewHiddenBeforeTransition = overlayView?.isHidden ?? false
        overlayView?.setHidden(true, animated: true)
        
        super.dismiss(animated: flag) {
            let isStillOnscreen = self.view.window != nil
            if isStillOnscreen && !isOverlayViewHiddenBeforeTransition {
                self.overlayView?.setHidden(false, animated: true)
            }
            completion?()
        }
    }
    
}


// MARK: - Function

extension MediaBrowserViewController {
    private func initialSetup(with initialMedia: MediaFileBrowsable?, referenceView: UIView?) {
        if let mediaFile = initialMedia {
            setUpPageViewController(mediaFile: mediaFile)
            setUpTransition(startingView: referenceView, startingMedia: mediaFile)
        } else if let mediaFile = dataSource.first {
            setUpPageViewController(mediaFile: mediaFile)
            setUpTransition(startingView: referenceView, startingMedia: mediaFile)
        }
        setupOverlayView()
    }
    
    private func setUpPageViewController(mediaFile: MediaFileBrowsable) {
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewController.OptionsKey.interPageSpacing: 16.0])
        pageViewController.view.backgroundColor = UIColor.clear
        pageViewController.dataSource = self
        pageViewController.delegate = self
        let photoViewController = initMediaFileDetailViewController(mediaFile: mediaFile)
        pageViewController.setViewControllers([photoViewController], direction: .forward, animated: false, completion: nil)
        
        view.backgroundColor = djiFileManagerTheme.backgroundColor
    }
    
    private func setUpTransition(startingView: UIView?, startingMedia: MediaFileBrowsable?) {
        mediaFileTransitionDelegate.transitionAnimator.startingView = startingView
        mediaFileTransitionDelegate.transitionAnimator.endingView = currentMediaFileViewController?.scalableImageView.imageView
        mediaFileTransitionDelegate.transitionAnimator.scaleAnimatedImage = startingMedia?.thumbnailImage
        modalPresentationStyle = .custom
        transitioningDelegate = mediaFileTransitionDelegate
        modalPresentationCapturesStatusBarAppearance = true
    }
    
    private func setupOverlayView() {
        overlayView = MediaFileOverlayView()
        overlayView?.topToolBar.topToolBarDelegate = self
        overlayView?.bottomToolBar.bottomToolBarDelegate = self
        view.addSubview(overlayView!)
        overlayView?.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        overlayView?.setHidden(false, animated: false)
        guard let currentMedia = currentMedia as? MediaFileModel else { return }
        overlayView?.topToolBar.titleItem.title = currentMedia.djiMediaFile.fileName
    }
    
    private func initMediaFileDetailViewController(mediaFile: MediaFileBrowsable) -> MediaFileDetailViewController {
        let mediaFileViewController = MediaFileDetailViewController(mediaFile: mediaFile)
        singleTapGestureRecognizer.require(toFail: mediaFileViewController.scalableImageView.doubleTapGestureRecognizer)
        return mediaFileViewController
    }
    
    @objc private func backAction() {
        dismiss(animated: true, completion: nil)
    }
    
    private func deleteMediaFile() {
        guard let mediaFile = self.currentMedia as? MediaFileModel
            , let camera = DJISDKManager.product()?.camera
            , let mediaManager = camera.mediaManager else {
            let resultAlert = UIAlertController(title: L10n.deleteFail, message: "", preferredStyle: .alert)
            resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
            self.present(resultAlert, animated: true, completion: nil)
            return
        }
        
        let statusAlert = UIAlertController(title: L10n.deleting, message: "", preferredStyle: .alert)
        self.present(statusAlert, animated: true, completion: nil)
        
        firstly {
            mediaManager.deleteMediaFiles([mediaFile.djiMediaFile])
        }.done {
            statusAlert.dismiss(animated: true) {
                self.dismiss(animated: true, completion: nil)
            }
            if let index = self.dataSource.index(where: { $0 === mediaFile }) {
                self.delegate?.mediaBrowser(self, didDeletedMedia: mediaFile, at: index)
            }
        }.catch { error in
            statusAlert.dismiss(animated: true, completion: nil)
            let resultAlert = UIAlertController(title: L10n.deleteFail, message: error.localizedDescription, preferredStyle: .alert)
            resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
            self.present(resultAlert, animated: true, completion: nil)
        }
    }
}


// MARK: - Gesture Recognizers

extension MediaBrowserViewController {
    @objc private func handlePanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .began {
            mediaFileTransitionDelegate.interactiveDismissal = true
            dismiss(animated: true, completion: nil)
        } else {
            mediaFileTransitionDelegate.interactiveDismissal = gestureRecognizer.state != .ended
            mediaFileTransitionDelegate.transitionAnimator.startingView = pageViewController.view
            mediaFileTransitionDelegate.interactiveAnimator.handlePanWithPanGestureRecognizer(gestureRecognizer, viewToPan: pageViewController.view, anchorPoint: CGPoint(x: view.bounds.midX, y: view.bounds.midY))
        }
    }
    
    @objc private func handleSingleTapGestureRecognizer(_ gestureRecognizer: UITapGestureRecognizer) {
        if view.backgroundColor == UIColor.black {
            view.backgroundColor = djiFileManagerTheme.backgroundColor
        } else {
            view.backgroundColor = .black
        }
        guard let overlayView = overlayView else { return }
        overlayView.setHidden(!overlayView.isHidden, animated: true)
    }
}


// MARK: - UIPageViewControllerDataSource

extension MediaBrowserViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let mediaFileDetailViewController = viewController as? MediaFileDetailViewController,
            let index = dataSource.index(where: { $0 === mediaFileDetailViewController.mediaFile }),
            let mediaFile = mediaFileAtIndex(index - 1) else { return nil }
        return initMediaFileDetailViewController(mediaFile: mediaFile)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let mediaFileDetailViewController = viewController as? MediaFileDetailViewController,
            let index = dataSource.index(where: { $0 === mediaFileDetailViewController.mediaFile }),
            let mediaFile = mediaFileAtIndex(index + 1) else { return nil }
        return initMediaFileDetailViewController(mediaFile: mediaFile)
    }
    
    public func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished, let mediaFile = currentMedia as? MediaFileModel {
            overlayView?.topToolBar.titleItem.title = mediaFile.djiMediaFile.fileName
        }
    }
    
    private func mediaFileAtIndex(_ index: Int) -> MediaFileBrowsable? {
        if (index < dataSource.count && index >= 0) {
            return dataSource[index]
        } else {
            return nil
        }
    }
}


// MARK: - TopToolBarDelegate

extension MediaBrowserViewController: TopToolBarDelegate {
    public func leftBarButtonDidClicked() {
        dismiss(animated: true, completion: nil)
    }
    
    public func rightBarButtonDidClicked() {
        let mediaFileInfoVC = MediaFileInfoViewController()
        mediaFileInfoVC.mediaFile = currentMedia
        present(mediaFileInfoVC, animated: true, completion: nil)
    }
}


// MARK: - BottomToolBarDelegate

extension MediaBrowserViewController: BottomToolBarDelegate {
    func downloadButtonDidClicked() {
        guard let mediaFile = (currentMedia as? MediaFileModel)?.djiMediaFile else {
            let alert = UIAlertController(title: MediaFileManagerError.fileTypeNotMatch.errorDescription, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let resultAlert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
        
        let statusAlert = UIAlertController(title: L10n.downloading, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel) { _ in
            mediaFile.stopFetchingFileData(completion: nil)
        }
        statusAlert.addAction(cancelAction)
        present(statusAlert, animated: true, completion: nil)
        
        MediaFileManager.downloadMediaFile(mediaFile) { (progress) in
            statusAlert.message = mediaFile.fileName + ": " + String(format: "%.2f", progress) + "%"
        }.done {
            statusAlert.dismiss(animated: true) {
                resultAlert.message = L10n.downloadSuccess
                self.present(resultAlert, animated: true, completion: nil)
            }
        }.catch { error in
            statusAlert.dismiss(animated: true) {
                resultAlert.title = L10n.downloadFail
                resultAlert.message = error.localizedDescription
                self.present(resultAlert, animated: true, completion: nil)
            }
        }
    }
    
    func shareButtonDidClicked() {
        // TODO: - If the file is Video
        guard let mediaFile = currentMedia as? MediaFileModel,
            let image = mediaFile.thumbnailImage else { return }
        
        let activityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        if UIDevice.current.userInterfaceIdiom == .phone {
            present(activityViewController, animated: true, completion: nil)
        } else {
            let popoverController = activityViewController.popoverPresentationController
            popoverController?.sourceView = view
            present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func deleteButtonDidClicked() {
        let alert = UIAlertController(title: L10n.confirmDelete, message: "", preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: L10n.confirm, style: .destructive) { _ in
            self.deleteMediaFile()
        }
        alert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
        alert.addAction(deleteAction)
        present(alert, animated: true, completion: nil)
    }
}
