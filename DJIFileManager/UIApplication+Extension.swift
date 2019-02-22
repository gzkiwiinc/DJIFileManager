//
//  UIApplication+Extension.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/6.
//  Copyright © 2018年 kiwi. All rights reserved.
//

import Foundation

extension UIApplication {
    
    /// get the current presented ViewController
    ///
    /// - Parameter rootController: specific the root controller
    /// - Returns: current presented ViewController
    static func presentedViewController(rootController: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        
        if let navigationController = rootController as? UINavigationController {
            return presentedViewController(rootController: navigationController.visibleViewController)
        }
        
        if let tabBarController = rootController as? UITabBarController {
            if let selectedController = tabBarController.selectedViewController {
                return presentedViewController(rootController: selectedController)
            }
        }
        
        if let presented = rootController?.presentedViewController {
            return presentedViewController(rootController: presented)
        }
        
        return rootController
    }
}
