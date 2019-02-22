//
//  TopToolBar.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/27.
//

import UIKit

protocol TopToolBarDelegate: class {
    func leftBarButtonDidClicked()
    func rightBarButtonDidClicked()
}

extension TopToolBarDelegate {
    func leftBarButtonDidClicked() {}
    func rightBarButtonDidClicked() {}
}

class TopToolBar: UIToolbar {
    
    weak var topToolBarDelegate: TopToolBarDelegate?
    
    var leftBarButton: UIBarButtonItem!
    var titleItem: UIBarButtonItem!
    var rightBarButton: UIBarButtonItem!

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = djiFileManagerTheme.backgroundColor
        barTintColor = djiFileManagerTheme.backgroundColor
        isTranslucent = false
        clipsToBounds = true
        
        leftBarButton = UIBarButtonItem(image: Asset.btnNavBack.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backAction))
        titleItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        titleItem.tintColor = djiFileManagerTheme.lightTextColor
        rightBarButton = UIBarButtonItem(title: L10n.detail, style: .plain, target: self, action: #selector(checkDetailAction))
        rightBarButton.tintColor = djiFileManagerTheme.themeColor
        
        let gapBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        setItems([leftBarButton, gapBarButtonItem, titleItem, gapBarButtonItem, rightBarButton], animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func backAction() {
        topToolBarDelegate?.leftBarButtonDidClicked()
    }
    
    @objc func checkDetailAction() {
        topToolBarDelegate?.rightBarButtonDidClicked()
    }
}
