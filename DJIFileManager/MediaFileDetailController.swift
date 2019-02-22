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

    lazy private(set) var scalableImageView: ScalableImageView = {
        let scalableImageView = ScalableImageView()
        scalableImageView.frame = view.bounds
        scalableImageView.image = mediaFile.thumbnailImage
        return scalableImageView
    }()
    lazy private var avPlayer = AVPlayer()
    lazy private(set) var playButton = UIButton()

    
    public init(mediaFile: MediaFileBrowsable) {
        self.mediaFile = mediaFile
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scalableImageView)
        view.addSubview(playButton)
        
        playButton.setImage(Asset.btnFilePlay.image, for: .normal)
        playButton.addTarget(self, action: #selector(playButtonDidClicked), for: .touchUpInside)
        playButton.isHidden = true
        playButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        scalableImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        guard let mediaFile = mediaFile as? MediaFileModel else { return }
        let mediaType = mediaFile.djiMediaFile.mediaType
        if mediaType == .MP4 || mediaType == .MOV {
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        scalableImageView.frame = view.bounds
    }
    
    @objc private func playButtonDidClicked() {
        guard let mediaFile = (mediaFile as? MediaFileModel)?.djiMediaFile
            , mediaFile.mediaType == .MP4 || mediaFile.mediaType == .MOV else {
            let alert = UIAlertController(title: MediaFileManagerError.fileTypeNotMatch.errorDescription, message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
            present(alert, animated: true, completion: nil)
            return
        }
        
        let statusAlert = UIAlertController(title: L10n.downloading, message: "", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: L10n.cancel, style: .cancel) { _ in
            mediaFile.stopFetchingFileData(completion: nil)
        }
        statusAlert.addAction(cancelAction)
        UIApplication.presentedViewController()?.present(statusAlert, animated: true, completion: nil)
        
        MediaFileManager.downloadVideo(mediaFile: mediaFile) { (progress) in
            statusAlert.message = mediaFile.fileName + ": " + String(format: "%.2f", progress) + "%"
        }.done { videoURL in
            statusAlert.dismiss(animated: true) {
                self.avPlayer.replaceCurrentItem(with: AVPlayerItem(url: videoURL))
                let playerViewController = AVPlayerViewController()
                playerViewController.player = self.avPlayer
                self.present(playerViewController, animated: true) {
                    playerViewController.player?.play()
                }
            }
        }.catch { error in
            statusAlert.dismiss(animated: true) {
                let resultAlert = UIAlertController(title: L10n.downloadFail, message: error.localizedDescription, preferredStyle: .alert)
                resultAlert.addAction(UIAlertAction(title: L10n.confirm, style: .default))
                self.present(resultAlert, animated: true, completion: nil)
            }
        }
    }
}
