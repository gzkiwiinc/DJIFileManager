//
//  PlaceholderStateView.swift
//  DJIFileManager
//
//  Created by Hanson on 2019/2/19.
//  Copyright © 2019 kiwi. All rights reserved.
//

import UIKit

class PlaceholderStateView: UIView {
    
    var imageView = UIImageView()
    var infoLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 14)
        infoLabel.textColor = djiFileManagerTheme.lightTextColor
        addSubview(imageView)
        addSubview(infoLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        infoLabel.snp.makeConstraints { (make) in
            make.left.equalTo(28.5)
            make.right.equalTo(-28.5)
            make.top.equalTo(imageView.snp.bottom).offset(32)
        }
    }
    
    func setup(state: State) {
        infoLabel.text = state.description
        imageView.image = state.stateImage
    }
}

extension PlaceholderStateView {
    enum State {
        case loading, timeout, noData, fail
        
        var description: String {
            switch self {
            case .loading:
                return L10n.loadingList
            case .timeout:
                return L10n.loadingTimeout
            case .noData:
                return L10n.noMediaFiles
            case .fail:
                return L10n.loadingFail
            }
        }
        
        var stateImage: UIImage {
            switch self {
            case .loading:
                return Asset.imageDroneLoading.image
            case .timeout:
                return Asset.imageDroneTimeout.image
            case .noData:
                return Asset.imageDroneError.image
            case .fail:
                return Asset.imageDroneError.image
            }
        }
    }
}
