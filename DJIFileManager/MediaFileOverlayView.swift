//
//  MediaFileOverlayView.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/8/24.
//

import UIKit
import DJISDK

class MediaFileOverlayView: UIView {
    
    lazy var bottomToolBar = BottomToolBar()
    lazy var topToolBar = TopToolBar()
    
    private let bottomSafeAreaView = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bottomToolBar.clipsToBounds = true
        bottomSafeAreaView.backgroundColor = djiFileManagerTheme.backgroundColor
        addSubview(topToolBar)
        addSubview(bottomToolBar)
        addSubview(bottomSafeAreaView)
    
        topToolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            } else {
                make.top.equalTo(20)
            }
        }
        bottomToolBar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(49)
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
        }
        bottomSafeAreaView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.equalTo(self.snp.bottom)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if let hitView = super.hitTest(point, with: event), hitView != self {
            return hitView
        }
        return nil
    }
    
    func setHidden(_ hidden: Bool, animated: Bool) {
        if isHidden == hidden {
            return
        }
        if animated {
            isHidden = false
            alpha = hidden ? 1.0 : 0.0
            UIView.animate(
                withDuration: 0.3,
                delay: 0.0,
                options: [.allowAnimatedContent, .allowUserInteraction],
                animations: {
                    self.alpha = hidden ? 0.0 : 1.0
                },
                completion: { result in
                    self.alpha = 1.0
                    self.isHidden = hidden
                })
        } else {
            isHidden = hidden
        }
    }
}
