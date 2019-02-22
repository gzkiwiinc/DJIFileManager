//
//  BundleToken.swift
//  DJIFileManager
//
//  Created by Hanson on 2019/2/18.
//  Copyright © 2019 kiwi. All rights reserved.
//

import Foundation

public final class BundleToken {
    /// 是否是demo测试，资源获取路径会有不同
    public static var isInternalTest = false
    
    static var frameworkBundle: Bundle {
        return Bundle(for: BundleToken.self)
    }
    
    static var resourcesBundle: Bundle {
        if BundleToken.isInternalTest {
            return Bundle(url: BundleToken.frameworkBundle.bundleURL)!
        } else {
            return Bundle(url: BundleToken.frameworkBundle.bundleURL.appendingPathComponent("DJIFileManager.bundle"))!
        }
    }
}
