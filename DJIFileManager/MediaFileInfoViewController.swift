//
//  MediaFileInfoViewController.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/28.
//

import UIKit

class MediaFileInfoViewController: UIViewController {

    var mediaFile: MediaFileBrowsable? {
        didSet {
            reload()
        }
    }
    
    var playButton = UIButton()
    var topToolBar = TopToolBar()
    var imageView = UIImageView()
    var tableView = UITableView()
    var dataSource = [MediaFileAttribute]()
    
    private let cellId = "MediaFileInfoTableViewCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = djiFileManagerTheme.backgroundColor
        
        topToolBar.leftBarButton.image = nil
        topToolBar.rightBarButton.title = L10n.cancel
        topToolBar.topToolBarDelegate = self
        imageView.image = mediaFile?.thumbnailImage
        playButton.setImage(Asset.btnFilePlay.image, for: .normal)
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.allowsSelection = false
        tableView.separatorStyle = .none
        tableView.backgroundColor = djiFileManagerTheme.backgroundColor
        tableView.register(MediaFileInfoTableViewCell.self, forCellReuseIdentifier: cellId)
        
        view.addSubview(topToolBar)
        view.addSubview(imageView)
        view.addSubview(playButton)
        view.addSubview(tableView)
        
        topToolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(20)
            }
        }
        imageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(topToolBar.snp.bottom).offset(20)
            make.width.equalTo(160)
            make.height.equalTo(120)
        }
        playButton.snp.makeConstraints { make in
            make.center.equalTo(imageView.snp.center)
        }
        tableView.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(32)
        }
        
        reload()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func reload() {
        guard let mediaFile = mediaFile as? MediaFileModel else { return }
        topToolBar.titleItem.title = mediaFile.djiMediaFile.fileName
        let mediaType = mediaFile.djiMediaFile.mediaType
        if mediaType == .MP4 || mediaType == .MOV {
            dataSource = MediaFileAttribute.videoData
            playButton.isHidden = false
        } else {
            dataSource = MediaFileAttribute.photoData
            playButton.isHidden = true
        }
        tableView.reloadData()
    }
}

extension MediaFileInfoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MediaFileInfoTableViewCell
        cell.titleLabel.text = dataSource[indexPath.row].description
        if let mediaFile = mediaFile as? MediaFileModel {
            cell.infoLabel.text = mediaFile.djiMediaFile.getStringValueOfAttribute(dataSource[indexPath.row])
        }
        return cell
    }
}

extension MediaFileInfoViewController: TopToolBarDelegate {
    func rightBarButtonDidClicked() {
        dismiss(animated: true, completion: nil)
    }
}

extension MediaFileAttribute {
    static let photoData: [MediaFileAttribute] = [.date, .size]
    static let videoData: [MediaFileAttribute] = [.date, .size, .dimension, duration, format]
}
