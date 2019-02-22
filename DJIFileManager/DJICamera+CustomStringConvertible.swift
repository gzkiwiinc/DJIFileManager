//
//  DJICamera+Description.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/11.
//  Copyright © 2018年 kiwi. All rights reserved.
//

import DJISDK

extension DJICameraVideoFrameRate: CustomStringConvertible {
    public var description: String {
        switch self {
        case .rate23dot976FPS:
            return "23.976fps"
        case .rate24FPS:
            return "24fps"
        case .rate25FPS:
            return "25fps"
        case .rate29dot970FPS:
            return "29.97fps"
        case .rate30FPS:
            return "30fps"
        case .rate47dot950FPS:
            return "47.95fps"
        case .rate48FPS:
            return "48fps"
        case .rate50FPS:
            return "50fps"
        case .rate59dot940FPS:
            return "59.94fps"
        case .rate60FPS:
            return "60fps"
        case .rate90FPS:
            return "90fps"
        case .rate96FPS:
            return "96fps"
        case .rate100FPS:
            return "100fps"
        case .rate120FPS:
            return "120fps"
        case .rate8dot7FPS:
            return "8.7fps"
        case .rateUnknown:
            return "unknown"
        }
    }
}

extension DJICameraVideoResolution: CustomStringConvertible {
    public var description: String {
        switch self {
        case .resolution336x256:
            return "336x256"
        case .resolution640x480:
            return "640x480"
        case .resolution640x512:
            return "640x512"
        case .resolution1280x720:
            return "1280x720"
        case .resolution1920x1080:
            return "1920x1080"
        case .resolution2704x1520:
            return "2704x1520"
        case .resolution2720x1530:
            return "2720x1530"
        case .resolution3712x2088:
            return "3712x2088"
        case .resolution3840x1572:
            return "3840x1572"
        case .resolution3840x2160:
            return "3840x2160"
        case .resolution3944x2088:
            return "3944x2088"
        case .resolution4096x2160:
            return "4096x2160"
        case .resolution4608x2160:
            return "4608x2160"
        case .resolution4608x2592:
            return "4608x2592"
        case .resolution5280x2160:
            return "5280x2160"
        case .resolution5760x3240:
            return "5760x3240"
        case .resolution6016x3200:
            return "6016x3200"
        case .resolutionMax:
            return "maximum resolution"
        case .resolutionNoSSDVideo:
            return "SSD video resolution is unset"
        case .resolution2048x1080:
            return "2048x1080"
        case .resolution2688x1512:
            return "2688x1512"
        case .resolution5280x2972:
            return "5280x2972"
        case .resolution640x360:
            return "640x360"
        case .resolutionUnknown:
            return "unknown"
        }
    }
}
