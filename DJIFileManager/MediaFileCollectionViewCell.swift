//
//  MediaFileCollectionViewCell.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/23.
//  Copyright © 2018年 kiwi. All rights reserved.
//

import UIKit

class MediaFileCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    var infoLabel: UILabel!
    var overlayView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        imageView = UIImageView()
        infoLabel = UILabel()
        infoLabel.textColor = UIColor.white
        infoLabel.font = UIFont.systemFont(ofSize: 12)
        overlayView = UIView()
        overlayView.backgroundColor = djiFileManagerTheme.themeColor.withAlphaComponent(0.4)
        overlayView.layer.borderWidth = 2
        overlayView.layer.borderColor = djiFileManagerTheme.themeColor.cgColor
        overlayView.isHidden = true
        
        contentView.addSubview(imageView)
        contentView.addSubview(infoLabel)
        contentView.addSubview(overlayView)
        imageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { make in
            make.right.equalTo(-4)
            make.bottom.equalTo(-4)
        }
        overlayView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(model: MediaFileModel) {
        imageView.image = model.thumbnailImage
        overlayView.isHidden = !model.isSelected
        let mediaType = model.djiMediaFile.mediaType
        if mediaType == .MOV || mediaType == .MP4 {
            infoLabel.text = FormatterUtility.durationTimeFormatter.string(from: Double(model.djiMediaFile.durationInSeconds)) ?? ""
            infoLabel.isHidden = false
        } else {
            infoLabel.isHidden = true
        }
    }
    
}
