//
//  DemoHelper.swift
//  droneDemo
//
//  Created by Hanson on 2018/8/22.
//  Copyright © 2018年 hanson. All rights reserved.
//

import UIKit

class DemoHelper {
    
    class func showAlert(title: String = "", message: String = "", on viewController: UIViewController? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        if let viewController = viewController {
            viewController.present(alert, animated: true, completion: nil)
        } else {
            UIApplication.shared.keyWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        }
    }
}
