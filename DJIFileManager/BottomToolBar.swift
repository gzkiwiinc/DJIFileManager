//
//  BottomToolBar.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/27.
//

import UIKit

protocol BottomToolBarDelegate: class {
    func downloadButtonDidClicked()
    func shareButtonDidClicked()
    func deleteButtonDidClicked()
}

extension BottomToolBarDelegate {
    func downloadButtonDidClicked() {}
    func shareButtonDidClicked() {}
    func deleteButtonDidClicked() {}
}

class BottomToolBar: UIToolbar {

    weak var bottomToolBarDelegate: BottomToolBarDelegate?
    
    var downLoadButton: UIBarButtonItem!
    var shareButton: UIBarButtonItem!
    var deleteButton: UIBarButtonItem!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = djiFileManagerTheme.backgroundColor
        barTintColor = djiFileManagerTheme.backgroundColor
        isTranslucent = false
        
        downLoadButton = UIBarButtonItem(image: Asset.btnFileDownload.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(downloadAction))
        shareButton = UIBarButtonItem(image: Asset.btnFileShare.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(shareAction))
        deleteButton = UIBarButtonItem(image: Asset.btnFileDelete.image.withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(deleteAction))
        let gapBarButtonItem =  UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        setItems([downLoadButton, gapBarButtonItem, shareButton, gapBarButtonItem, deleteButton], animated: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func downloadAction() {
        bottomToolBarDelegate?.downloadButtonDidClicked()
    }
    
    @objc func shareAction() {
        bottomToolBarDelegate?.shareButtonDidClicked()
    }
    
    @objc func deleteAction() {
        bottomToolBarDelegate?.deleteButtonDidClicked()
    }
}
