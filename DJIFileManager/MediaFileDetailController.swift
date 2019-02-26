//
//  MediaFileDetailViewController.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import UIKit
import DJISDK
import PromiseKit
import AVKit

class MediaFileDetailViewController: UIViewController {
    
    var mediaFile: MediaFileBrowsable
    var scalableImageView = ScalableImageView()

    lazy private var avPlayer = AVPlayer()
    lazy private(set) var playButton = UIButton()

    private let indicator = UIActivityIndicatorView(style: .whiteLarge)
    
    public init(mediaFile: MediaFileBrowsable) {
        self.mediaFile = mediaFile
        if let mediaFile = mediaFile as? MediaFileModel {
            scalableImageView.image = mediaFile.djiMediaFile.preview ?? mediaFile.thumbnailImage
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchPreviewImage()
    }
    
    override func viewDidLayoutSubviews() {
        scalableImageView.frame = view.bounds
    }
    
    private func setupView() {
        view.addSubview(scalableImageView)
        view.addSubview(playButton)
        view.addSubview(indicator)
        
        playButton.setImage(Asset.btnFilePlay.image, for: .normal)
        playButton.addTarget(self, action: #selector(playButtonDidClicked), for: .touchUpInside)
        playButton.isHidden = true
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        scalableImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        indicator.center = view.center
        
        guard let mediaFile = mediaFile as? MediaFileModel else { return }
        let mediaType = mediaFile.djiMediaFile.mediaType
        if mediaType == .MP4 || mediaType == .MOV {
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
        }
    }
    
    // get the preview image which has higher resolution
    private func fetchPreviewImage() {
        guard let mediaFile = mediaFile as? MediaFileModel
            , mediaFile.djiMediaFile.preview == nil else { return }
        indicator.startAnimating()
        firstly {
            mediaFile.djiMediaFile.fetchPreview()
        }.done {
            self.scalableImageView.image = mediaFile.djiMediaFile.preview
        }.ensure {
            self.indicator.stopAnimating()
        }.catch { (error) in
            print("fetch preview image failed: \(error.localizedDescription)")
        }
    }
    
    @objc private func playButtonDidClicked() {
        if let mediaFile = (mediaFile as? MediaFileModel)?.djiMediaFile
         , let cacheUrl = MediaFileManager.getMediaFileCacheURL(mediaFile: mediaFile) {
            playVideo(url: cacheUrl)
        } else {
            let noticeAlert = UIAlertController(title: L10n.notice, message: L10n.downloadAndPlay, preferredStyle: .alert)
            noticeAlert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel, handler: nil))
            noticeAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default) { _ in
                self.downloadAndPlayVideo()
            })
            present(noticeAlert, animated: true, completion: nil)
        }
    }
    
    private func downloadAndPlayVideo() {
        guard let mediaFile = (mediaFile as? MediaFileModel)?.djiMediaFile
            , mediaFile.mediaType == .MP4 || mediaFile.mediaType == .MOV else {
            let alert = UIAlertController(title: MediaFileManagerError.fileTypeNotMatch.errorDescription, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let statusAlert = UIAlertController(title: L10n.downloading, message: "", preferredStyle: .alert)
        statusAlert.addAction(UIAlertAction(title: L10n.cancel, style: .cancel) { _ in
            mediaFile.stopFetchingFileData(completion: nil)
        })
        present(statusAlert, animated: true, completion: nil)
        
        MediaFileManager.downloadVideo(mediaFile: mediaFile) { (progress) in
            statusAlert.message = mediaFile.fileName + ": " + String(format: "%.2f", progress) + "%"
        }.then { videoUrl in
            PhotoLibraryManager.saveVideo(url: videoUrl).map { _ -> URL in
                return videoUrl
            }
        }.done { videoUrl in
            statusAlert.dismiss(animated: true) {
                self.playVideo(url: videoUrl)
            }
        }.catch { error in
            statusAlert.dismiss(animated: true) {
                let resultAlert = UIAlertController(title: L10n.downloadFail, message: error.localizedDescription, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }
    }
    
    private func playVideo(url: URL) {
        avPlayer.replaceCurrentItem(with: AVPlayerItem(url: url))
        let playerViewController = AVPlayerViewController()
        playerViewController.player = self.avPlayer
        present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}
