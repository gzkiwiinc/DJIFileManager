//
//  FormatterUtility.swift
//  DJIFileManager
//
//  Created by Hanson on 2018/9/13.
//  Copyright © 2018年 kiwi. All rights reserved.
//

import Foundation

enum FormatterUtility {
    static let byteCountFormatter = ByteCountFormatter()
    
    /// format the duration of video to "00:00:00"
    static let durationTimeFormatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .positional
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        return formatter
    }()
}
