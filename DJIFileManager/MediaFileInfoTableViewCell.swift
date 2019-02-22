//
//  MediaFileInfoTableViewCell.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/4.
//  
//

import UIKit

class MediaFileInfoTableViewCell: UITableViewCell {

    var titleLabel: UILabel!
    var infoLabel: UILabel!
    var bottomLine: UIView!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        backgroundColor = djiFileManagerTheme.backgroundColor
        
        titleLabel = UILabel()
        titleLabel.textColor = djiFileManagerTheme.textColor
        titleLabel.font = UIFont.systemFont(ofSize: 16)
        
        infoLabel = UILabel()
        infoLabel.textColor = djiFileManagerTheme.lightTextColor
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        
        bottomLine = UIView()
        bottomLine.backgroundColor = djiFileManagerTheme.separatorColor
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(bottomLine)
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
        }
        infoLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-16)
        }
        bottomLine.snp.makeConstraints { make in
            make.height.equalTo(1)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.bottom.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
